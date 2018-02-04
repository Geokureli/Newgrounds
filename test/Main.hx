package;

import openfl.display.Stage;
import openfl.events.Event;
import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.MainScreen;
import io.newgrounds.test.ui.Page;
import io.newgrounds.test.ui.Button;

import io.newgrounds.NG;
import io.newgrounds.components.Component;

import openfl.display.Sprite;
import openfl.text.TextField;

class Main extends Sprite {
	
	public function new() {
		super();
		
		var page = new IntroScreenSwf();
		addChild(page);
		
		new IntroPage(page, onStart.bind(page));
	}
	
	function onStart(page:IntroScreenSwf):Void {
		
		removeChild(page);
		page = null;
		
		addChild(new MainScreen());
	}
}

class IntroPage extends Page<Component> {
	
	var _onStart:Void->Void;
	
	var _appId:TextField;
	var _sessionId:TextField;
	var _start:Button;
	
	public function new (target:IntroScreenSwf, onStart:Void->Void):Void {
		super();
		_onStart = onStart;
		
		_appId = target.appId;
		_sessionId = target.sessionId;
		_start = new Button(target.start, onStartClick);
		
		if (target.stage != null)
			init(target.stage);
		else
			target.addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	function onAdded(e:Event = null):Void {
		
		init(cast(e.currentTarget, IntroScreenSwf).stage);
	}
	
	function init(stage:Stage):Void {
		
		var id = NG.getSessionId(stage);
		
		_sessionId.text = id != null ? id : "";
	}
	
	function onStartClick():Void {
		
		NG.create(_appId.text, _sessionId.text);
		NG.core.verbose = true;
		
		_onStart();
	}
}