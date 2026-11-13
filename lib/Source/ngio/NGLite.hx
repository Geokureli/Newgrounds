package ngio;

import haxe.PosInfos;
import haxe.io.Bytes;
import ngio.components.ComponentList;
import ngio.crypto.Cipher;
import ngio.crypto.EncodingFormat;
import ngio.crypto.Encryption;
import ngio.data.AppData;
import ngio.debug.Logger;
import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Error;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.BaseResultData;
import ngio.net.results.Result;
import ngio.net.results.SessionResultData;
import ngio.tools.WebTools;

using ngio.net.Outcome.OutcomeTools;
using ngio.net.Outcome.TypedOutcomeTools;

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
class NGLite extends ngio.cores.CallableCore
{
	static public var core(default, null):Null<NGLite>;
	static public final onCoreReady = new Dispatcher();
	
	#if (js || flash)
	static public final web = new WebTools();
	#end
	
	@:deprecated("debug is deprecated, use appData.debug, instead")
	public var debug(get, set):Bool;
	inline function get_debug() return appData.debug;
	inline function set_debug(value:Bool) return appData.debug = value;
	
	@:deprecated("appId is deprecated, use appData.appId, instead")
	/** The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project. */
	public var appId(get, never):String;
	inline function get_appId() return appData.id;
	
	@:deprecated("sessionId is deprecated, use appData.sessionId, instead")
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
	@:deprecated("encryptionHandler is deprecated, use appData.encryptionHandler, instead")
	public var encryptionHandler(get, set):(String)->String;
	function get_encryptionHandler():(String)->String return appData.encryption.encrypt;
	function set_encryptionHandler(value:(String)->String) {
		
		appData.encryption = FUNC(value);
		return value;
	}
	
	/** 
	 * Iniitializes the API, call before utilizing any other component.
	 * 
	 * @param app       Info needed to connect with the NG.io server for a specific project
	 * @param callback  If a sessionId was given, this will be called with the outcome of that
	 *                  login attempt.
	**/
	public function new(app:AppData, ?callback:(ngio.net.LoginOutcome)->Void) {
		
		super(app, new Logger((any, ?pos)->haxe.Log.trace('[Newgrounds API] :: ${any}', pos)));
		
		if (appData.sessionId != null) {
			
			callList.add(calls.app.checkSession())
				.addOutcomeHandler(checkInitialSession.bind(callback))
				.send();
		}
	}
	
	function checkInitialSession(callback:Null<(ngio.net.LoginOutcome)->Void>, outcome:CallOutcome<SessionResultData>) {
		
		switch(outcome)
		{
			case SUCCESS(_): callback.safe(SUCCESS);
			case FAIL(error): initialSessionFail(callback, error);
		}
	}
	
	function initialSessionFail(callback:Null<(ngio.net.LoginOutcome)->Void>, error:CallError) {
		
		appData.sessionId = null;
		
		callback.safe(FAIL(ERROR(error)));
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API.
	 * 
	 * This is not the only way to create an instance, nor is NG a forced singleton, but it's the
	 * only way to set the static NG.core.
	 * 
	 * @param app       The unique ID of your app as found in the 'API Tools' tab of your
	 *                  Newgrounds.com project.
	 * @param callback  If a sessionId was given, this will be called with the outcome of that
	 *                   login attempt.
	 * 
	 * @see createAndCheckSession
	**/	inline static public function create(app:AppData, ?callback) {
		
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
	@:deprecated("createAndCheckSession(myAppId, mySessionId) is deprecated, use AppData to define these args")
	overload static public inline extern function createAndCheckSession
	( appId = "test"
	, backupSessionId:String = null
	, ?callback:(ngio.net.LoginOutcome)->Void
	):Void {
		
		createAndCheckSession({ id: appId, sessionId: backupSessionId }, callback);
	}
	
	/**
	 * Creates NG.core, looks in loader vars for a session (only works when playing on Newgrounds).
	 * If a session is not found, the backup session is used.
	 * 
	 * This is not the only way to create an instance, nor is NG a forced singleton, but it's the
	 * only way to set the static NG.core.
	 * 
	 * @param app       Info needed to connect with the NG.io server for a specific project
	 * @param callback  If a sessionId was given or found, this will be called with the
	 *                  outcome of that login attempt.
	**/
	overload static public inline extern function createAndCheckSession(app:AppData, ?callback) {
		
		app.sessionId = web.getSessionId() ?? app.sessionId;
		create(app, callback);
	}
	
	#if (js || flash)
	/** Get the current URL */
	@:deprecated("getUrl is deprecated, use web.getUrl, instead")
	inline static public function getUrl():String {
		
		return web.getUrl();
	}
	
	/** Look for a NG.io session ID, if available */
	@:deprecated("getSessionId is deprecated, use web.getSessionId, instead")
	static public function getSessionId():String {
		
		return web.getSessionId();
	}
	#else
	/** Get the current URL */
	@:deprecated("getUrl will not be available on non web targets")
	inline static public function getUrl():Null<String> {
		
		return null;
	}
	
	/** Look for a NG.io session ID, if available */
	@:deprecated("getSessionId will not be available on non web targets")
	static public function getSessionId():Null<String> {
		
		return null;
	}
	#end
	
	// -------------------------------------------------------------------------------------------
	//                                       ENCRYPTION
	// -------------------------------------------------------------------------------------------
	
	@:deprecated("setupEncryption is deprecated, use appData.encryption, instead")
	public function setupEncryption
	( key   :String
	, cipher:Cipher         = AES_128
	, format:EncodingFormat = BASE_64
	) {
		
		appData.encryption = EncryptionTools.create(cipher, key, format);
	}
	
	@:deprecated("initEncryption is deprecated, use `appData.encryption`, instead")
	inline public function initEncryption(key, cipher = Cipher.RC4, format = BASE_64) {
		
		setupEncryption(key, cipher, format);
	}
}

@:deprecated("io.newgrounds.NGLite.LoginOutcome is deprecated, use ngio.net.LoginOutcome, instead")
typedef LoginOutcome = ngio.net.LoginOutcome;

@:deprecated("io.newgrounds.NGLite.LoginOutcome.LoginFail is deprecated, use ngio.net.LoginOutcome.LoginFail, instead")
typedef LoginFail = ngio.net.LoginOutcome.LoginFail;

@:deprecated("io.newgrounds.NGLite.LoginOutcome.LoginCancel is deprecated, use ngio.net.LoginOutcome.LoginCancel, instead")
typedef LoginCancel = ngio.net.LoginOutcome.LoginCancel;