package io.newgrounds;

#if ng_lite
typedef NG = NGLite; //TODO: test and make lite UI
#else
import haxe.Timer;
import io.newgrounds.NGLite;
import io.newgrounds.lists.ExternalAppList;
import io.newgrounds.lists.MedalList;
import io.newgrounds.lists.SaveSlotList;
import io.newgrounds.lists.ScoreBoardList;
import io.newgrounds.net.Call;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.data.Session;
import io.newgrounds.net.data.User;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.LoginOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.BaseResultData;
import io.newgrounds.net.results.Result;
import io.newgrounds.net.results.SessionResultData;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.utils.Dispatcher;
import io.newgrounds.utils.WebTools;

using io.newgrounds.net.outcomes.Outcome.OutcomeTools;
using io.newgrounds.net.outcomes.Outcome.TypedOutcomeTools;

/**
 * The Newgrounds API for Haxe.
 * Contains many things ripped from MSGhero
 *   - https://github.com/MSGhero/NG.hx
 * @author GeoKureli
 */
class NG extends NGLite {
	
	static public var core(default, null):NG;
	static public final onCoreReady:Dispatcher = new Dispatcher();
	
	static public final web = new WebTools();
	
	// --- DATA
	
	/** The logged in user */
	public var user(get, never):Null<User>;
	function get_user():Null<User> {
		
		if (_session == null)
			return null;
		
		return _session.user;
	}
	public var passportUrl(get, never):Null<String>;
	function get_passportUrl():Null<String> {
		
		if (_session == null || _session.status != SessionStatus.REQUEST_LOGIN)
			return null;
		
		return _session.passportUrl;
	}
	
	public final medals:MedalList;
	public final scoreBoards:ScoreBoardList;
	public final saveSlots:SaveSlotList;
	public final externalApps:ExternalAppList;
	
	// --- EVENTS
	
	public final onLogin:Dispatcher;
	public final onLogOut:Dispatcher;
	
	@:deprecated("Use medals.onLoad")
	public var onMedalsLoaded(get, never):Dispatcher;
	inline function get_onMedalsLoaded() return medals.onLoad;
	
	@:deprecated("Use scoreBoards.onLoad")
	public var onScoreBoardsLoaded(get, never):Dispatcher;
	inline function get_onScoreBoardsLoaded() return scoreBoards.onLoad;
	
	@:deprecated("Use saveSlots.onLoad")
	public var onSaveSlotsLoaded(get, never):Dispatcher;
	inline function get_onSaveSlotsLoaded() return saveSlots.onLoad;
	
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
	public function new(app, ?callback) {
		
		host = getHost();
		onLogin = new Dispatcher();
		onLogOut = new Dispatcher();
		
		super(app, callback);
		
		medals = new MedalList(this);
		saveSlots = new SaveSlotList(this);
		scoreBoards = new ScoreBoardList(this);
		externalApps = new ExternalAppList(this);
		
		attemptingLogin = appData.sessionId != null;
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	overload static public inline extern function create
	( appId = "test"
	, ?sessionId:String
	, debug = false
	, ?callback
	):Void {
		
		create({id: appId, sessionId: sessionId, debug: debug }, callback);
	}
	
	overload static public inline extern function create(app, ?callback) {
		
		core = new NG(app, callback);
		
		onCoreReady.dispatch();
	}
	
	/**
	 * Creates NG.core, and tries to create a session. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	 * @param appId         The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param debug         Enables debug features and verbose responses from the server
	 * @param backupSession A unique session id used to identify the active user.
	 */
	overload static public inline extern function createAndCheckSession
	( appId = "test"
	, debug = false
	, ?backupSession:String
	, ?callback:(LoginOutcome)->Void
	):Void {
		
		createAndCheckSession({ id: appId, sessionId: backupSession, debug:debug }, callback);
	}
	
	overload static public inline extern function createAndCheckSession(app, ?callback) {
		
		app.sessionId = web.getSessionId() ?? app.sessionId;
		
		create(app, callback);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                         APP
	// -------------------------------------------------------------------------------------------
	
	override function checkInitialSession
	( callback:Null<(LoginOutcome)->Void>
	, outcome:CallOutcome<SessionResultData>
	):Void {
		
		onSessionReceive(outcome, callback, null);
	}
	
	/**
	 * Begins the login process
	 * 
	 * @param callback          Called when the login is a success.
	 * @param passportCallback  Called when the passportUrl has been identified, call
	 *                          NG.core.openPassportLink to open the link continue the process.
	 *                          Leave as null to open the url automatically NOTE: Browser games
	 *                          must open links on click events or else it will be blocked by the
	 *                          popup blocker.
	 */
	public function requestLogin
	( callback:(LoginOutcome)->Void = null
	, passportHandler:String->Void = null
	):Void {
		
		if (attemptingLogin) {
			
			throw "cannot request another login until the previous attempt is complete";
		}
		
		if (loggedIn) {
			
			logger.logError("cannot log in, already logged in");
			callback.safe(SUCCESS);
			return;
		}
		
		attemptingLogin = true;
		_loginCancelled = false;
		_passportCallback = null;
		
		calls.app.startSession(true)
			.addOutcomeHandler(onSessionReceive.bind(_, callback, passportHandler))
			.send();
	}
	
	function onSessionReceive
	( outcome:CallOutcome<SessionResultData>
	, callback:Null<(LoginOutcome)->Void>
	, passportHandler:String->Void
	):Void {
		
		switch(outcome)
		{
			case SUCCESS(data): _session = data.session;
			case FAIL(error):
				
				appData.sessionId = null;
				endLogin();
				
				callback.safe(FAIL(ERROR(error)));
				return;
		}
		
		appData.sessionId = _session.id;
		
		logger.logVerbose('session started - status: ${_session.status}');
		
		if (_session.status == REQUEST_LOGIN) {
			
			_passportCallback = checkSessionStatus.bind(callback);
			if (passportHandler != null)
				passportHandler(passportUrl);
			else
				openPassportUrl();
			
		} else
			checkSessionStatus(callback);
	}
	
	/**
	 * Call this once the passport link is established and it will load the passport URL and
	 * start checking for session connect periodically
	 */
	public function openPassportUrl():Void {
		
		if (passportUrl != null) {
			
			logger.logVerbose('loading passport: ${passportUrl}');
			openPassportHelper(passportUrl);
			dispatchPassportCallback();
			
		} else
			logger.logError("Cannot open passport");
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
				case name: logger.logError("Unhandled systemName: " + name);
			}
		#else
			logger.logError("Could not open passport url, unhandled target");
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
			
			logger.logVerbose("dispatching passport callback");
			var callback = _passportCallback;
			_passportCallback = null;
			callback();
		}
	}
	
	function checkSession(outcome:CallOutcome<SessionResultData>, callback:Null<(LoginOutcome)->Void>) {
		
		switch (outcome) {
			
			case FAIL(_):
				logger.log("login cancelled via passport");
				
				endLoginAndCall(callback, FAIL(CANCELLED(PASSPORT)));
				
			case SUCCESS(data):
				
				logger.logVerbose("Session received");
				
				_session = data.session;
				checkSessionStatus(callback);
		}
	}
	
	function checkSessionStatus(callback:Null<(LoginOutcome)->Void>) {
		
		if (_loginCancelled)
		{
			logger.log("login cancelled via cancelLoginRequest");
			
			endLoginAndCall(callback, FAIL(CANCELLED(MANUAL)));
			return;
		}
		
		switch(_session.status) {
			
			case USER_LOADED:
				
				loggedIn = true;
				endLoginAndCall(callback, SUCCESS);
				onLogin.dispatch();
				
			case REQUEST_LOGIN:
				
				function sendCheckSession() {
					
					calls.app.checkSession()
						.addOutcomeHandler(checkSession.bind(_, callback))
						.send();
				}
				
				// Wait 3 seconds and try again
				timer(3.0,
					function():Void {
						
						logger.logVerbose("3s elapsed, checking session again");
						
						// Check if cancelLoginRequest was called
						if (!_loginCancelled)
							sendCheckSession();
						else {
							
							logger.log("login cancelled via cancelLoginRequest");
							endLoginAndCall(callback, FAIL(CANCELLED(MANUAL)));
						}
					}
				);
				
			case SESSION_EXPIRED:
				
				logger.log("login cancelled via passport");
				
				// The user cancelled the passport
				endLoginAndCall(callback, FAIL(CANCELLED(PASSPORT)));
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
	
	function endLogin():Void {
		
		attemptingLogin = false;
		_loginCancelled = false;
	}
	
	function endLoginAndCall(callback:Null<(LoginOutcome)->Void>, outcome:LoginOutcome) {
		
		endLogin();
		
		callback.safe(outcome);
	}
	
	public function logOut(onComplete:(Outcome<CallError>)->Void = null) {
		
		var call = calls.app.endSession()
			.addSuccessHandler(onLogOutSuccessful);
		
		if (onComplete != null)
			call.addOutcomeHandler((o)->onComplete(o.toUntyped()));
		
		call.addSuccessHandler(onLogOut.dispatch)
			.send();
	}
	
	function onLogOutSuccessful():Void {
		
		_session = null;
		appData.sessionId = null;
		loggedIn = false;
	}
	
	/**
	 * Loads the info for each medal
	 *
	 * @param callback   Whether the request was successful, or an error message
	**/
	public function requestMedals(?callback:(Outcome<CallError>)->Void):Void {
		
		medals.loadList(callback);
	}
	
	/**
	 * Loads the info for each score board, but not the scores
	 *
	 * @param callback   Whether the request was successful, or an error message
	**/
	@:deprecated("use scoreBoards.loadList")
	public function requestScoreBoards(?callback:(Outcome<CallError>)->Void):Void {
		
		scoreBoards.loadList(callback);
	}
	
	/**
	 * Loads the info for each cloud save slot, including the last save time and size
	 *
	 * @param callback   Whether the request was successful, or an error message.
	**/
	@:deprecated("use saveSlots.loadList")
	inline public function requestSaveSlots(?callback:(Outcome<CallError>)->Void):Void {
		
		saveSlots.loadList(callback);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       HELPERS
	// -------------------------------------------------------------------------------------------
	
	/**
	 * Fetches the server's current date-time in ISO 8601 format.
	 * 
	 * @param callback       The handler for the server response.
	 */
	public function requestServerIsoTime(callback:(TypedOutcome<String, CallError>)->Void) {
		
		calls.gateway.getDatetime()
			.addOutcomeHandler(
				(outcome)->switch (outcome) {
					
					case SUCCESS(data): callback(SUCCESS(data.dateTime));
					case FAIL(error)  : callback(FAIL(error));
				}
			)
			.send();
	}
	
	/**
	 * Fetches a timestamp from the server and creates a Date object based on the UNIX timestamp.
	 * 
	 * @param callback       The handler for the server response.
	 * @param useServerTime  If true, the unix timestamp is offset by the difference the user's
	 *                       timezone and the server's. Ex: If the user is -5:00 and the server
	 *                       is -4:00 it adds an hour. 
	 *                       Note: this is a hack to show the date-time at the NG headquarters.
	 */
	public function requestServerTime(callback:(TypedOutcome<Date, CallError>)->Void, useServerTime = false) {
		
		calls.gateway.getDatetime()
			.addOutcomeHandler((outcome)->switch(outcome) {
				
				case FAIL(error): callback(FAIL(error));
				case SUCCESS(data):
					
					if (useServerTime)
						callback(SUCCESS(data.getServerDate()));
					else
						callback(SUCCESS(data.getDate()));
			})
			.send();
	}
	
	function timer(delay:Float, callback:Void->Void):Void {
		
		final timer = new Timer(Std.int(delay * 1000));
		timer.run = function func():Void {
			
			timer.stop();
			callback();
		}
	}
	
	static var urlParser:EReg = ~/^(?:http[s]?:\/\/)?([^:\/\s]+)(:[0-9]+)?((?:\/\w+)*\/)([\w\-\.]+[^#?\s]+)([^#\s]*)?(#[\w\-]+)?$/i;//TODO:trim
	/** Used to get the current web host of your game. */
	static public function getHost():String {
		
		final url = web.getUrl();
		
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
