package;

import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.MainScreen;
import io.newgrounds.test.ui.Page;
import io.newgrounds.test.ui.Button;

import io.newgrounds.NG;
import io.newgrounds.components.Component;

import openfl.display.Sprite;
import openfl.text.TextField;

class Main extends Sprite {
	
	var _layout:IntroScreenSwf;
	
	public function new() {
		super();
		
		_layout = new IntroScreenSwf();
		addChild(_layout);
		
		new IntroPage(_layout, onStart);
	}
	
	function onStart():Void {
		
		removeChild(_layout);
		_layout = null;
		
		addChild(new MainScreen());
	}
}

class IntroPage extends Page<Component> {
	
	var _appId:TextField;
	var _start:Button;
	var _onStart:Void->Void;
	
	public function new (target:IntroScreenSwf, onStart:Void->Void):Void {
		super();
		
		_appId = target.appId;
		_start = new Button(target.start, onStartClick);
		
		_onStart = onStart;
	}
	
	function onStartClick():Void {
		
		NG.createCore(_appId.text);
		NG.core.verbose = true;
		
		_onStart();
	}
}