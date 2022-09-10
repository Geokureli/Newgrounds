package io.newgrounds;

import haxe.io.Bytes;
import haxe.PosInfos;

import io.newgrounds.Call;
import io.newgrounds.components.ComponentList;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.utils.Dispatcher;

#if !(js || flash || cpp || neko || hl)
	#error "Target not supported, use: Flash, JS, cpp or maybe neko or hashlink";
#end

/**
 * The barebones NG.io API. Allows API calls with code completion
 * and retrieves server data via strongly typed Objects
 * 
 * Contains many things ripped from MSGhero's repo
 *   - https://github.com/MSGhero/NG.hx
 * 
 * @author GeoKureli
 */
class NGLite {
	
	static public var core(default, null):NGLite;
	static public var onCoreReady(default, null):Dispatcher = new Dispatcher();
	
	/** Enables verbose logging */
	public var verbose:Bool;
	public var debug:Bool;
	/** The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project. */
	public var appId(default, null):String;
	/** The name of the host the game is being played on */
	public var host:String;
	
	@:isVar
	public var sessionId(default, set):String;
	function set_sessionId(value:String):String {
		
		return this.sessionId = value == "" ? null : value;
	}
	
	/** Components used to call the NG server directly */
	public var calls(default, null):ComponentList;
	
	/**
	 * Converts an object to an encrypted string that can be decrypted by the server.
	 * Set your preffered encrypter here,
	 * or just call setDefaultEcryptionHandler with your app's encryption settings
	**/
	public var encryptionHandler:String->String;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component.
	 * 
	 * @param appId      The unique ID of your app as found in the 'API Tools' tab of your
	 *                   Newgrounds.com project.
	 * @param sessionId  A unique session id used to identify the active user.
	 * @param debug      Enables debug features and verbose responses from the server
	 * @param callback   If a sessionId was given, this will be called with the outcome of that
	 *                   login attempt.
	**/
	public function new
	( appId = "test"
	, ?sessionId:String
	, debug = false
	, ?callback:(LoginOutcome)->Void
	) {
		
		this.appId = appId;
		this.sessionId = sessionId;
		this.debug = debug;
		
		calls = new ComponentList(this);
		
		if (this.sessionId != null) {
			
			calls.app.checkSession()
				.addOutcomeHandler(checkInitialSession.bind(callback))
				.send();
		}
	}
	
	function checkInitialSession(callback:Null<(LoginOutcome)->Void>, outcome:CallOutcome<SessionData>):Void {
		
		switch(outcome)
		{
			case SUCCESS(_): callback.safe(SUCCESS);
			case FAIL(error): initialSessionFail(callback, error);
		}
	}
	
	function initialSessionFail(callback:Null<(LoginOutcome)->Void>, error:CallError):Void {
		
		sessionId = null;
		
		callback.safe(FAIL(ERROR(error)));
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API.
	 * 
	 * This is not the only way to create an instance, nor is NG a forced singleton, but it's the
	 * only way to set the static NG.core.
	 * 
	 * @param appId      The unique ID of your app as found in the 'API Tools' tab of your
	 *                   Newgrounds.com project.
	 * @param sessionId  A unique session id used to identify the active user.
	 * @param callback   If a sessionId was given, this will be called with the outcome of that
	 *                   login attempt.
	 * 
	 * @see createAndCheckSession
	**/
	static public function create
	( appId            = "test"
	, sessionId:String = null
	, ?callback:(LoginOutcome)->Void
	):Void {
		
		core = new NGLite(appId, sessionId, false, callback);
		
		onCoreReady.dispatch();
	}
	
	/**
	 * Creates NG.core, looks in loader vars for a session (only works when playing on Newgrounds).
	 * If a session is not found, the backup session is used.
	 * 
	 * This is not the only way to create an instance, nor is NG a forced singleton, but it's the
	 * only way to set the static NG.core.
	 * 
	 * @param appId            The unique ID of your app as found in the 'API Tools' tab of your
	 *                         Newgrounds.com project.
	 * @param backupSessionId  A unique session id used to identify the active user.
	 * @param callback         If a sessionId was given or found, this will be called with the
	 *                         outcome of that login attempt.
	**/
	static public function createAndCheckSession
	( appId = "test"
	, backupSessionId:String = null
	, ?callback:(LoginOutcome)->Void
	):Void {
		
		var session = getSessionId();
		if (session == null)
			session = backupSessionId;
		
		create(appId, session, callback);
	}
	
	inline static public function getUrl():String {
		
		#if js
			return js.Browser.document.location.href;
		#elseif flash
			return flash.Lib.current.stage.loaderInfo != null
				? flash.Lib.current.stage.loaderInfo.url
				: null;
		#else
			return null;
		#end
	}
	
	static public function getSessionId():String {
		
		#if js
			
			var url = getUrl();
			
			// Check for URL params
			var index = url.indexOf("?");
			if (index != -1) {
				
				// Check for session ID in params
				for (param in url.substr(index + 1).split("&")) {
					
					index = param.indexOf("=");
					if (index != -1 && param.substr(0, index) == "ngio_session_id")
						return param.substr(index + 1);
				}
			}
			
		#elseif flash
			
			if (flash.Lib.current.stage.loaderInfo != null
			&&  Reflect.hasField(flash.Lib.current.stage.loaderInfo.parameters, "ngio_session_id"))
				return Reflect.field(flash.Lib.current.stage.loaderInfo.parameters, "ngio_session_id");
			
		#end
		
		return null;
		
		// --- EXAMPLE LOADER PARAMS
		//{ "1517703669"                : ""
		//, "ng_username"               : "GeoKureli"
		//, "NewgroundsAPI_SessionID"   : "F1LusbG6P8Qf91w7zeUE37c1752563f366688ac6153996d12eeb111a2f60w2xn"
		//, "NewgroundsAPI_PublisherID" : 1
		//, "NewgroundsAPI_UserID"      : 488329
		//, "NewgroundsAPI_SandboxID"   : "5a76520e4ae1e"
		//, "ngio_session_id"           : "0c6c4e02567a5116734ba1a0cd841dac28a42e79302290"
		//, "NewgroundsAPI_UserName"    : "GeoKureli"
		//}
	}
	
	// -------------------------------------------------------------------------------------------
	//                                   CALLS
	// -------------------------------------------------------------------------------------------
	
	var _queuedCalls:Array<ICallable> = new Array<ICallable>();
	var _pendingCalls:Array<ICallable> = new Array<ICallable>();
	
	@:allow(io.newgrounds.Call)
	@:generic
	function queueCall<T:BaseData>(call:Call<T>):Void {
		
		logVerbose('queued - ${call.component}');
		
		_queuedCalls.push(call);
		checkQueue();
	}
	
	@:allow(io.newgrounds.Call)
	@:generic
	function markCallPending<T:BaseData>(call:Call<T>):Void {
		
		_pendingCalls.push(call);
		
		call.addOutcomeHandler((_)->{ 
			
			_pendingCalls.remove(call);
			checkQueue();
		});
	}
	
	function checkQueue():Void {
		
		if (_pendingCalls.length == 0 && _queuedCalls.length > 0)
			_queuedCalls.shift().send();
	}
	
	// -------------------------------------------------------------------------------------------
	//                                   LOGGING / ERRORS
	// -------------------------------------------------------------------------------------------
	
	/** Called internally, set this to your preferred logging method */
	dynamic public function log(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		haxe.Log.trace('[Newgrounds API] :: ${any}', pos);
	}
	
	/** used internally, logs if verbose is true */
	inline public function logVerbose(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		if (verbose)
			log(any, pos);
	}
	
	/** Used internally. Logs by default, set this to your preferred error handling method */
	dynamic public function logError(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		log('Error: $any', pos);
	}
	
	/** used internally, calls log error if the condition is false. EX: if (assert(data != null, "null data")) */
	inline public function assert(condition:Bool, msg:Dynamic, ?pos:PosInfos):Bool {//TODO: limit access via @:allow
		if (!condition)
			logError(msg, pos);
		
		return condition;
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       ENCRYPTION
	// -------------------------------------------------------------------------------------------
	
	
	public function setupEncryption
	( key   :String
	, cipher:Cipher         = AES_128
	, format:EncodingFormat = BASE_64
	) {
		
		encryptionHandler = null;
		
		var encrypt = cipher.generateEncrypter(format.decode(key));
		if (encrypt != null) {
			
			encryptionHandler = function (data) {
				
				return format.encode(encrypt(Bytes.ofString(data)));
			}
		}
	}
	
	@:deprecated("initEncryption is deprecated, use `setupEncryption`, now that AES-128 is the default")
	inline public function initEncryption(key, cipher = RC4, format = BASE_64) {
		
		setupEncryption(key, cipher, format);
	}
}

typedef LoginOutcome = Outcome<LoginFail>;

enum LoginFail
{
	/** The login was aborted. */
	CANCELLED(type:LoginCancel);
	
	/** The login attempt failed, somewhere. */
	ERROR(error:CallError);
}

enum LoginCancel
{
	/** The login was cancelled in the passport web page. */
	PASSPORT;
	
	/** The session was abandoned in this app. */
	MANUAL;
}
