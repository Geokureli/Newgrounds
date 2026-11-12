package io.newgrounds;

import haxe.PosInfos;
import haxe.io.Bytes;
import io.newgrounds.components.ComponentList;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.crypto.Encryption;
import io.newgrounds.debug.Logger;
import io.newgrounds.net.Call;
import io.newgrounds.net.data.AppData;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.LoginOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.BaseResultData;
import io.newgrounds.net.results.Result;
import io.newgrounds.net.results.SessionResultData;
import io.newgrounds.utils.Dispatcher;

using io.newgrounds.net.outcomes.Outcome.OutcomeTools;
using io.newgrounds.net.outcomes.Outcome.TypedOutcomeTools;

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
class NGLite extends CallableCore {
	
	static public var core(default, null):Null<NGLite>;
	static public final onCoreReady = new Dispatcher();
	
	public var debug(get, set):Bool;
	inline function get_debug() return appData.debug;
	inline function set_debug(value:Bool) return appData.debug = value;
	
	/** The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project. */
	public var appId(get, never):String;
	inline function get_appId() return appData.id;
	
	public var sessionId(get, set):String;
	function get_sessionId():String return appData.sessionId;
	function set_sessionId(value:String):String {
		
		return appData.sessionId = value == "" ? null : value;
	}
	
	/**
	 * Converts an object to an encrypted string that can be decrypted by the server.
	 * Set your preffered encrypter here,
	 * or just call setDefaultEcryptionHandler with your app's encryption settings
	**/
	public var encryptionHandler(get, set):(String)->String;
	function get_encryptionHandler():(String)->String return appData.encryption.encrypt;
	function set_encryptionHandler(value:(String)->String) {
		
		appData.encryption = FUNC(value);
		return value;
	}
	
	
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
	public function new(app:AppData, ?callback:(LoginOutcome)->Void) {
		
		super(app, new Logger((any, ?pos)->haxe.Log.trace('[Newgrounds API] :: ${any}', pos)));
		
		if (this.sessionId != null) {
			
			callList.add(calls.app.checkSession())
				.addOutcomeHandler(checkInitialSession.bind(callback))
				.send();
		}
	}
	
	function checkInitialSession(callback:Null<(LoginOutcome)->Void>, outcome:CallOutcome<SessionResultData>):Void {
		
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
	overload static public inline extern function create(appId = "test", ?sessionId:String, ?callback):Void {
		
		createHelper({id: appId, sessionId: sessionId, debug: appId == "test" }, callback);
	}
	
	overload static public inline extern function createHelper(app:AppData, ?callback):Void {
		
		core = new NGLite(app, callback);
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
	overload static public inline extern function createAndCheckSession
	( appId = "test"
	, backupSessionId:String = null
	, ?callback:(LoginOutcome)->Void
	):Void {
		
		createAndCheckSessionHelper({ id: appId, sessionId: backupSessionId }, callback);
	}
	
	overload static public inline extern function createAndCheckSession(app:AppData, callback) {
		
		createAndCheckSessionHelper(app, callback);
	}
	
	static public function createAndCheckSessionHelper(app:AppData, ?callback):Void {
		
		app.sessionId = getSessionId() ?? app.sessionId;
		createHelper(app, callback);
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
	
	// final _queuedCalls = new Array<ICallable>();
	// final _pendingCalls = new Array<ICallable>();
	
	// @:allow(io.newgrounds.net.Call)
	// @:generic
	// function queueCall<T:BaseResultData>(call:Call<T>):Void {
		
	// 	logger.logVerbose('queued - ${call.component}');
		
	// 	_queuedCalls.push(call);
	// 	checkQueue();
	// }
	
	// @:allow(io.newgrounds.net.Call)
	// @:generic
	// function markCallPending<T:BaseResultData>(call:Call<T>):Void {
		
	// 	_pendingCalls.push(call);
		
	// 	call.addOutcomeHandler((_)->{ 
			
	// 		_pendingCalls.remove(call);
	// 		checkQueue();
	// 	});
	// }
	
	// function checkQueue():Void {
		
	// 	if (_pendingCalls.length == 0 && _queuedCalls.length > 0)
	// 		_queuedCalls.shift().send();
	// }
	
	// -------------------------------------------------------------------------------------------
	//                                       ENCRYPTION
	// -------------------------------------------------------------------------------------------
	
	
	public function setupEncryption
	( key   :String
	, cipher:Cipher         = AES_128
	, format:EncodingFormat = BASE_64
	) {
		
		appData.encryption = EncryptionTools.create(cipher, key, format);
	}
	
	@:deprecated("initEncryption is deprecated, use `setupEncryption`, now that AES-128 is the default")
	inline public function initEncryption(key, cipher = Cipher.RC4, format = BASE_64) {
		
		setupEncryption(key, cipher, format);
	}
}