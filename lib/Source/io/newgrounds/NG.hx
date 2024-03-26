package io.newgrounds;

#if ng_lite
typedef NG = NGLite; //TODO: test and make lite UI
#else
import io.newgrounds.Call;
import io.newgrounds.NGLite;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Outcome;
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
import io.newgrounds.utils.SessionUtil;
#if (openfl < "4.0.0")
import openfl.utils.JNI;
#elseif (lime)
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
	@:deprecated("user is deprecated, use session.current.user")
	public var user(get, never):User;
	function get_user():User {
		
		final session = _session;
		if (session == null)
			return null;
		
		return session.user;
	}
	// Todo:deprecate
	public var passportUrl(get, never):String;
	function get_passportUrl():String {
		
		return session.getPassportUrl();
	}
	
	/** Helper for starting, ending and continuing sessions */
	public var session(default, null):SessionUtil;
	
	/** Helper for unlocking, and checking the unlock status of medals */
	public var medals(default, null):MedalList;
	
	/** Helper for posting, and retrieving scoreboards and scores */
	public var scoreBoards(default, null):ScoreBoardList;
	
	/** Helper for reading and writing to save slots */
	public var saveSlots(default, null):SaveSlotList;
	
	/** A list of external apps about which you may access limited information */
	public var externalApps(default, null):ExternalAppList;
	
	// --- EVENTS
	
	@:deprecated("Use NG.session.onLogIn")
	public var onLogin(get, never):Dispatcher;
	inline function get_onLogin() return session.onLogIn;
	
	@:deprecated("Use NG.session.onLogOut")
	public var onLogOut(get, never):Dispatcher;
	inline function get_onLogOut() return session.onLogOut;
	
	@:deprecated("Use NG.medals.onLoad")
	public var onMedalsLoaded(get, never):Dispatcher;
	inline function get_onMedalsLoaded() return medals.onLoad;
	
	@:deprecated("Use NG.scoreBoards.onLoad")
	public var onScoreBoardsLoaded(get, never):Dispatcher;
	inline function get_onScoreBoardsLoaded() return scoreBoards.onLoad;
	
	@:deprecated("Use NG.saveSlots.onLoad")
	public var onSaveSlotsLoaded(get, never):Dispatcher;
	inline function get_onSaveSlotsLoaded() return saveSlots.onLoad;
	
	// --- MISC
	
	@:deprecated("loggedIn is deprecated, use session.status")
	public var loggedIn(get, never):Bool;
	function get_loggedIn() {
		
		return session.status.match(LOGGED_IN(_));
	}
	
	@:deprecated("attemptingLogin is deprecated, use session.status")
	public var attemptingLogin(get, never):Bool;
	function get_attemptingLogin() {
		
		return switch (session.status) {
			
			case AWAITING_PASSPORT(_): true;
			case STARTING_NEW        : true;
			case CHECKING_STATUS(_)  : true;
			case LOGGED_OUT          : false;
			case LOGGED_IN(_)        : false;
		}
	}
	
	var _session(get, never):Session;
	function get__session() {
		
		return session.current;
	}
	
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
	, ?callback:(LoginOutcome)->Void
	) {
		
		host = getHost();
		
		session = new SessionUtil(this);
		medals = new MedalList(this);
		saveSlots = new SaveSlotList(this);
		scoreBoards = new ScoreBoardList(this);
		externalApps = new ExternalAppList(this);
		
		super(appId, null, debug);
		
		if (sessionId != null) {
			
			session.connectTo(sessionId, (outcome)->{
				
				callback(switch (outcome) {
					
					case SUCCESS(_)           : SUCCESS;
					case FAIL(EXPIRED)        : FAIL(CANCELLED(PASSPORT));
					case FAIL(CALL(error))    : FAIL(ERROR(error));
					case FAIL(CANCELLED(type)): FAIL(CANCELLED(type));
				});
			});
		}
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	static public function create
	( appId = "test"
	, ?sessionId:String
	, debug = false
	, ?callback:(LoginOutcome)->Void
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
	, ?callback:(LoginOutcome)->Void
	):Void {
		
		var sessionId = NGLite.getSessionId();
		if (sessionId == null)
			sessionId = backupSession;
		
		create(appId, sessionId, debug, callback);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                         APP
	// -------------------------------------------------------------------------------------------
	
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
	@:deprecated("requestLogin is deprecated, use session.startNew, instead")
	inline public function requestLogin
	( callback:(LoginOutcome)->Void = null
	, passportHandler:String->Void = null
	):Void {
		
		session.startNew(callback, passportHandler);
	}
	
	/**
	 * Call this once the passport link is established and it will load the passport URL and
	 * start checking for session connect periodically
	 */
	public function openPassportUrl():Void {
		
		session.openPassportUrl();
	}
	
	function openUrl(url:String):Void {
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
			logError('Could not open url: $url, unhandled target');
		#end
	}
	
	/**
	 * Call this once the passport link is established and it will start checking for session connect periodically
	 */
	public function onPassportUrlOpen():Void {
		
		// no longer needed
	}
	
	@:deprecated('cancelLoginRequest')
	public function cancelLoginRequest():Void {
		
		if (session.status.match(AWAITING_PASSPORT(_) | STARTING_NEW))
			session.cancel();
	}
	
	public function logOut(?onComplete:(Outcome<CallError>)->Void) {
		
		session.endCurrent(onComplete);
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
