package io.newgrounds.test;

import io.newgrounds.objects.Session.SessionStatus;

import openfl.utils.Timer;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.Lib;

class AppTest extends Test {
	
	public function new() {
		super();
		
		NG.core.app.startSession()
			.addSuccessHandler(onSessionStarted)
			.send();
	}
	
	function onSessionStarted():Void {
		
		trace('session started - status: ${NG.core.app.session.status}');
		
		if (NG.core.app.session.status == SessionStatus.REQUEST_LOGIN) {
			
			trace('loading passport: ${NG.core.app.session.passportUrl}');
			Lib.getURL(new URLRequest(NG.core.app.session.passportUrl));
			
			checkSession(onUserConnect);
		}
	}
	
	function checkSession(userLoadedCallback:Void->Void):Void {
		
		if (NG.core.app.session.status == SessionStatus.USER_LOADED)
			userLoadedCallback();
		else if (NG.core.app.session.status == SessionStatus.REQUEST_LOGIN){
			
			var call = NG.core.app.checkSession()
				.addSuccessHandler(checkSession.bind(userLoadedCallback));
			
			timer(3.0, call.send);
			
		} else
			trace("sesion expired");
	}
	
	function onUserConnect():Void {
		
		trace("User connected");
		timer(3.0, endSession);
	}
	
	function endSession():Void {
		
		NG.core.app.endSession()
			.addSuccessHandler(complete)
			.send();
	}
	
	function timer(delay:Float, callback:Void->Void):Void {
		
		var timer = new Timer(delay * 1000.0, 1);
		
		function func(e:TimerEvent):Void {
			
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, func);
			callback();
		}
		
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, func);
		timer.start();
	}
}
