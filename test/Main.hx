package;

import flash.text.TextFieldType;
import io.newgrounds.test.ui.CheckBox;
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
	var _autoConnect:CheckBox;
	var _stage:Stage;
	
	public function new (target:IntroScreenSwf, onStart:Void->Void):Void {
		super();
		_onStart = onStart;
		
		_appId = target.appId;
		_sessionId = target.sessionId;
		_start = new Button(target.start, onStartClick);
		_autoConnect = new CheckBox(target.autoConnect, onAutoConnectToggle);
		
		if (target.stage != null)
			_stage = target.stage
		else
			target.addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	function onAdded(e:Event = null):Void {
		
		_stage = e.currentTarget;
	}
	
	function onAutoConnectToggle():Void {
		
		if (_autoConnect.on) {
			
			_sessionId.type = TextFieldType.DYNAMIC;
			_sessionId.selectable = false;
			_sessionId.backgroundColor = 0xE8E8E8;
			_sessionId.textColor = 0x666666;
		
		} else {
			
			_sessionId.type = TextFieldType.INPUT;
			_sessionId.selectable = true;
			_sessionId.backgroundColor = 0xFFFFFF;
			_sessionId.textColor = 0x000000;
		}
	}
	
	function onStartClick():Void {
		
		if (_autoConnect.on)
			NG.createAndConnect(_stage, _appId.text);
		else
			NG.create(_appId.text, _sessionId.text);
		
		NG.core.verbose = true;
		
		_onStart();
	}
}