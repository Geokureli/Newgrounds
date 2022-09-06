package io.newgrounds;

#if ng_lite
typedef NG = NGLite; //TODO: test and make lite UI
#else
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Result.SessionResult;
import io.newgrounds.objects.events.Result.MedalListResult;
import io.newgrounds.objects.events.Result.GetBoardsResult;
import io.newgrounds.objects.events.Result.LoadSlotsResult;
import io.newgrounds.objects.events.ResultType;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.User;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.objects.Session;
import io.newgrounds.utils.Dispatcher;
import io.newgrounds.utils.ExternalAppList;
import io.newgrounds.utils.MedalList;
import io.newgrounds.utils.SaveSlotList;
import io.newgrounds.utils.ScoreBoardList;
#if (openfl < "4.0.0")
import openfl.utils.JNI;
#else
import lime.system.JNI;
#end
import haxe.Timer;

/**
 * The Newgrounds API for Haxe.
 * Contains many things ripped from MSGhero
 *   - https://github.com/MSGhero/NG.hx
 * @author GeoKureli
 */
class NG extends NGLite {
	
	static public var core(default, null):NG;
	static public var onCoreReady(default, null):Dispatcher = new Dispatcher();
	
	// --- DATA
	
	/** The logged in user */
	public var user(get, never):User;
	function get_user():User {
		
		if (_session == null)
			return null;
		
		return _session.user;
	}
	public var passportUrl(get, never):String;
	function get_passportUrl():String {
		
		if (_session == null || _session.status != SessionStatus.REQUEST_LOGIN)
			return null;
		
		return _session.passportUrl;
	}
	public var medals(default, null):MedalList;
	public var scoreBoards(default, null):ScoreBoardList;
	public var saveSlots(default, null):SaveSlotList;
	public var externalApps(default, null):ExternalAppList;
	
	// --- EVENTS
	
	public var onLogin(default, null):Dispatcher;
	public var onLogOut(default, null):Dispatcher;
	
	@:deprecated("Use medals.onLoad")
	public var onMedalsLoaded(get, never):Dispatcher;
	inline function get_onMedalsLoaded()  return medals.onLoaded;
	
	@:deprecated("Use scoreBoards.onLoad")
	public var onScoreBoardsLoaded(get, never):Dispatcher;
	inline function get_onScoreBoardsLoaded()  return scoreBoards.onLoaded;
	
	@:deprecated("Use saveSlots.onLoad")
	public var onSaveSlotsLoaded(get, never):Dispatcher;
	inline function get_onSaveSlotsLoaded()  return saveSlots.onLoaded;
	
	// --- MISC
	
	public var loggedIn(default, null) = false;
	public var attemptingLogin(default, null) = false;
	
	var _loginCancelled = false;
	var _passportCallback:Void->Void;
	
	var _session:Session;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component
	 * 
	 * @param appId     The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param sessionId A unique session id used to identify the active user.
	**/
	public function new
	( appId = "test"
	, ?sessionId:String
	, debug = false
	, ?callback:(ResultType)->Void
	) {
		
		host = getHost();
		onLogin = new Dispatcher();
		onLogOut = new Dispatcher();
		
		medals = new MedalList(this);
		saveSlots = new SaveSlotList(this);
		scoreBoards = new ScoreBoardList(this);
		externalApps = new ExternalAppList(this);
		
		attemptingLogin = sessionId != null;
		
		super(appId, sessionId, debug, onSessionFail);
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	static public function create
	( appId = "test"
	, ?sessionId:String
	, debug = false
	, ?callback:(ResultType)->Void
	):Void {
		
		core = new NG(appId, sessionId, debug, callback);
		
		onCoreReady.dispatch();
	}
	
	/**
	 * Creates NG.core, and tries to create a session. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	 * @param appId         The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param debug         Enables debug features and verbose responses from the server
	 * @param backupSession A unique session id used to identify the active user.
	 */
	static public function createAndCheckSession
	( appId = "test"
	, debug = false
	, ?backupSession:String
	, ?callback:(ResultType)->Void
	):Void {
		
		var session = NGLite.getSessionId();
		if (session == null)
			session = backupSession;
		
		create(appId, session, debug, callback);
		
		if (core.sessionId != null)
			core.attemptingLogin = true;
	}
	
	// -------------------------------------------------------------------------------------------
	//                                         APP
	// -------------------------------------------------------------------------------------------
	
	override function checkInitialSession
	( callback:(ResultType)->Void
	, response:Response<SessionResult>
	):Void {
		
		onSessionReceive(response, null, null, failHandler);
	}
	
	/**
	 * Begins the login process
	 * 
	 * @param onSuccess Called when the login is a success
	 * @param onPending Called when the passportUrl has been identified, call NG.core.openPassportLink 
	 *                  to open the link continue the process. Leave as null to open the url automatically
	 *                  NOTE: Browser games must open links on click events or else it will be blocked by
	 *                  the popup blocker.
	 * @param onFail    
	 * @param onCancel  Called when the user denies the passport connection.
	 */
	public function requestLogin
	( onSuccess:Void->Void  = null
	, onPending:Void->Void  = null
	, onFail   :Error->Void = null
	, onCancel :Void->Void  = null
	):Void {
		
		if (attemptingLogin) {
			
			logError("cannot request another login until the previous attempt is complete");
			return;
		}
		
		if (loggedIn) {
			
			logError("cannot log in, already logged in");
			return;
		}
		
		attemptingLogin = true;
		_loginCancelled = false;
		_passportCallback = null;
		
		var call = calls.app.startSession(true)
			.addDataHandler(onSessionReceive.bind(_, onSuccess, onPending, onFail, onCancel));
		
		if (onFail != null)
			call.addErrorHandler(onFail);
		
		call.send();
	}
	
	function onSessionReceive
	( response :Response<SessionResult>
	, onSuccess:Void->Void = null
	, onPending:Void->Void = null
	, onFail   :Error->Void = null
	, onCancel :Void->Void = null
	):Void {
		
		if (!response.success || !response.result.success) {
			
			sessionId = null;
			endLoginAndCall(null);
			
			if (onFail != null)
				onFail(!response.success ? response.error : response.result.error);
			
			return;
		}
		
		_session = response.result.data.session;
		sessionId = _session.id;
		
		logVerbose('session started - status: ${_session.status}');
		
		if (_session.status == SessionStatus.REQUEST_LOGIN) {
			
			_passportCallback = checkSession.bind(null, onSuccess, onCancel);
			if (onPending != null)
				onPending();
			else
				openPassportUrl();
			
		} else
			checkSession(null, onSuccess, onCancel);
	}
	
	/**
	 * Call this once the passport link is established and it will load the passport URL and
	 * start checking for session connect periodically
	 */
	public function openPassportUrl():Void {
		
		if (passportUrl != null) {
			
			logVerbose('loading passport: ${passportUrl}');
			openPassportHelper(passportUrl);
			dispatchPassportCallback();
			
		} else
			logError("Cannot open passport");
	}
	
	function openPassportHelper(url:String):Void {
		var window = "_blank";
		
		#if flash
			flash.Lib.getURL(new flash.net.URLRequest(url), window);
		#elseif js
			js.Browser.window.open(url, window);
		#elseif android
			JNI.createStaticMethod
				( "org/haxe/lime/GameActivity"
				, "openURL"
				, "(Ljava/lang/String;Ljava/lang/String;)V"
				) (url, window);
		#elseif sys
			switch Sys.systemName() {
				
				case 'Windows': Sys.command('start ${url}');
				case 'Linux': Sys.command('xdg-open ${url}');
				case 'Mac': Sys.command('open ${url}');
				case name: logError("Unhandled systemName: " + name);
			}
		#else
			logError("Could not open passport url, unhandled target");
		#end
	}
	
	/**
	 * Call this once the passport link is established and it will start checking for session connect periodically
	 */
	public function onPassportUrlOpen():Void {
		
		dispatchPassportCallback();
	}
	
	function dispatchPassportCallback():Void {
		
		if (_passportCallback != null) {
			
			logVerbose("dispatching passport callback");
			var callback = _passportCallback;
			_passportCallback = null;
			callback();
		}
	}
	
	function checkSession(response:Response<SessionResult>, onSuccess:Void->Void, onCancel:Void->Void):Void {
		
		if (_loginCancelled)
		{
			log("login cancelled via cancelLoginRequest");
			
			endLoginAndCall(onCancel);
			return;
		}
		
		if (response != null) {
			
			if (!response.success || !response.result.success) {
				
				log("login cancelled via passport");
				
				endLoginAndCall(onCancel);
				return;
			}
			
			logVerbose("Session received");
			_session = response.result.data.session;
		}
		
		if (_session.status == SessionStatus.USER_LOADED) {
			
			loggedIn = true;
			endLoginAndCall(onSuccess);
			onLogin.dispatch();
			
		} else if (_session.status == SessionStatus.REQUEST_LOGIN){
			
			var call = calls.app.checkSession()
				.addDataHandler(checkSession.bind(_, onSuccess, onCancel));
			
			// Wait 3 seconds and try again
			timer(3.0,
				function():Void {
					
					logVerbose("3s elapsed, checking session again");
					
					// Check if cancelLoginRequest was called
					if (!_loginCancelled)
						call.send();
					else {
						
						log("login cancelled via cancelLoginRequest");
						endLoginAndCall(onCancel);
					}
				}
			);
			
		} else {
			
			log("login cancelled via passport");
			
			// The user cancelled the passport
			endLoginAndCall(onCancel);
		}
	}
	
	public function cancelLoginRequest():Void {
		
		if (attemptingLogin)
		{
			_loginCancelled = true;
			// Pretend we opened the passport to process the client cancel.
			dispatchPassportCallback();
		}
	}
	
	function endLoginAndCall(callback:Void->Void):Void {
		
		attemptingLogin = false;
		_loginCancelled = false;
		
		if (callback != null)
			callback();
	}
	
	public function logOut(onComplete:Void->Void = null):Void {
		
		var call = calls.app.endSession()
			.addSuccessHandler(onLogOutSuccessful);
		
		if (onComplete != null)
			call.addSuccessHandler(onComplete);
		
		call.addSuccessHandler(onLogOut.dispatch)
			.send();
	}
	
	function onLogOutSuccessful():Void {
		
		_session = null;
		sessionId = null;
		loggedIn = false;
	}
	
	/**
	 * Loads the info for each medal
	 *
	 * @param callback   Whether the request was successful, or an error message
	**/
	public function requestMedals(?callback:ResultType->Void):Void {
		
		medals.loadList(callback);
	}
	
	/**
	 * Loads the info for each score board, but not the scores
	 *
	 * @param callback   Whether the request was successful, or an error message
	**/
	@:deprecated("use scoreBoards.loadList")
	public function requestScoreBoards(?callback:ResultType->Void):Void {
		
		scoreBoards.loadList(callback);
	}
	
	/**
	 * Loads the info for each cloud save slot, including the last save time and size
	 *
	 * @param loadFiles  If true, each slot's save file is also loaded.
	 * @param callback   Whether the request was successful, or an error message
	**/
	@:deprecated("use saveSlots.loadList")
	inline public function requestSaveSlots(loadFiles = false, ?callback:ResultType->Void):Void {
		
		saveSlots.loadList(loadFiles, callback);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       HELPERS
	// -------------------------------------------------------------------------------------------
	
	function timer(delay:Float, callback:Void->Void):Void {
		
		var timer = new Timer(Std.int(delay * 1000));
		timer.run = function func():Void {
			
			timer.stop();
			callback();
		}
	}
	
	static var urlParser:EReg = ~/^(?:http[s]?:\/\/)?([^:\/\s]+)(:[0-9]+)?((?:\/\w+)*\/)([\w\-\.]+[^#?\s]+)([^#\s]*)?(#[\w\-]+)?$/i;//TODO:trim
	/** Used to get the current web host of your game. */
	static public function getHost():String {
		
		var url = NGLite.getUrl();
		
		if (url == null || url == "")
			return "AppView";
		
		if (url.indexOf("file") == 0 || url.indexOf("127.0.0.1") != -1)
			return "LocalHost";
		
		if (urlParser.match(url))
			return urlParser.matched(1);
		
		return "Unknown";
	}
}
#end
