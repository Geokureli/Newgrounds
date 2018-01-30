package io.newgrounds;

import io.newgrounds.objects.User;
import haxe.ds.IntMap;

//TODO: Remove openfl dependancies 
import openfl.events.TimerEvent;
import openfl.Lib;
import openfl.net.URLRequest;
import openfl.utils.Timer;

import io.newgrounds.objects.Medal;
import io.newgrounds.objects.Session;
import io.newgrounds.objects.ScoreBoard;

/**
 * The Newgrounds API for Haxe.
 * Contains many things ripped from MSGhero
 *   - https://github.com/MSGhero/NG.hx
 * @author GeoKureli
 */
class NG extends NGLite {
	
	static public var core(default, null):NG;
	
	/** A unique session id used to identify the active user. */
	public var sessionId(get, never):String;
	public function get_sessionId():String {
		
		if (_session == null)
			return null;
		
		return _session.id;
	}

	/** The logged in user */
	public var user(get, never):User;
	public function get_user():User {
		
		if (_session == null)
			return null;
		
		return _session.user;
	}
	
	
	var _waitingForLogin:Bool;
	var _loginCancelled:Bool;
	
	var _session:Session;
	var _medals:IntMap<Medal>;
	var _scoreBoards:IntMap<ScoreBoard>;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component
	 * @param appId     The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param sessionId A unique session id used to identify the active user.
	**/
	public function new(appId:String = "test") {
		super(appId);
		
		_session = new Session(this);
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	static public function createCore(appId:String = "test"):Void {
		
		core = new NG(appId);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                         CALLS
	// -------------------------------------------------------------------------------------------
	
	inline function isCallSuccessful(data:Dynamic):Bool {
		
		if (!data.data.success)
			logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
		
		return data.data.success;
	}
	
	// -------------------------------------------------------------------------------------------
	//                                         APP
	// -------------------------------------------------------------------------------------------
	
	public function requestLogin
	( onLogin :Void->Void = null
	, onFail  :Void->Void = null
	, onCancel:Void->Void = null
	):Void {
		
		if (_waitingForLogin) {
			
			logError("cannot request another login until");
			return;
		}
		
		_waitingForLogin = true;
		_loginCancelled = false;
		
		var call = app.startSession(true);
		
		call.addErrorHandler(
			function (_):Void {
				_waitingForLogin = false;
				onFail();
			}
		);
		
		call.addDataHandler(
			function (data:Dynamic):Void {
				
				if (!isCallSuccessful(data)) {
					
					_waitingForLogin = false;
					
					if (onFail != null)
						onFail();
					
					return;
				}
				
				_session.parse(data.data.session);
				
				logVerbose('session started - status: ${_session.status}');
				
				if (_session.status == SessionStatus.REQUEST_LOGIN) {
					
					logVerbose('loading passport: ${_session.passportUrl}');
					// TODO: Remove openFL dependancy
					Lib.getURL(new URLRequest(_session.passportUrl));
					checkSession(null, onLogin, onCancel);
				}
			}
		);
		
		call.send();
	}
	
	function checkSession(data:Dynamic, onLogin:Void->Void, onCancel:Void->Void):Void {
		
		if (data != null) {
			
			if (!isCallSuccessful(data)) {
				// The user cancelled the passport
				
				endLoginAndCall(onCancel);
				return;
			}
			_session.parse(data.data.session);
		}
		
		if (_session.status == SessionStatus.USER_LOADED) {
			
			endLoginAndCall(onLogin);
			
		} else if (_session.status == SessionStatus.REQUEST_LOGIN){
			
			var call = app.checkSession()
				.addDataHandler(checkSession.bind(_, onLogin, onCancel));
			
			// Wait 3 seconds and try again
			timer(3.0,
				function():Void {
					
					// Check if cancelLoginRequest was called
					if (!_loginCancelled)
						call.send();
					else
						endLoginAndCall(onCancel);
				}
			);
			
		} else
			// The user cancelled the passport
			endLoginAndCall(onCancel);
	}
	
	public function cancelLoginRequest():Void {
		
		if (_waitingForLogin)
			_loginCancelled = true;
	}
	
	function endLoginAndCall(callback:Void->Void):Void {
		
		_waitingForLogin = false;
		_loginCancelled = false;
		
		if (callback != null)
			callback();
	}
	
	public function logOut():Void {
		
		app.endSession()
			.addSuccessHandler(onLogOutSuccessful)
			.send();
	}
	
	function onLogOutSuccessful():Void {
		
		_session.expire();
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       ENCRYPTION
	// -------------------------------------------------------------------------------------------
	
	public function loadMedals(onSuccess:Void->Void = null, onFail:Void->Void = null):Void {
		
		var call = medal.getList()
			.addDataHandler(onListReceived);
		
		if (onSuccess != null)
			call.addSuccessHandler(onSuccess);
		
		if (onFail != null)
			call.addErrorHandler(function(_):Void { onFail(); });
		
		call.send();
	}
	
	function onListReceived(data:Dynamic):Void {
		
		if (!isCallSuccessful(data))
			return;
		
		if (_medals == null) {
			
			_medals = new IntMap<Medal>();
			
			for (medalData in cast(data.data.medals, Array<Dynamic>)) {
				
				var medal = new Medal(this, medalData);
				_medals.set(medal.id, medal);
			}
		} else {
			
			for (medalData in cast(data.data.medals, Array<Dynamic>)) {
				
				_medals.get(medalData.id).parse(medalData);
			}
		}
		
		logVerbose('${data.data.medals.length} Medals received');
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       HELPERS
	// -------------------------------------------------------------------------------------------
	
	function timer(delay:Float, callback:Void->Void):Void {
		//TODO: remove openFL dependancy
		
		var timer = new Timer(delay * 1000.0, 1);
		
		function func(e:TimerEvent):Void {
			
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, func);
			callback();
		}
		
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, func);
		timer.start();
	}
}