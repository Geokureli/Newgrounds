package io.newgrounds.test;

import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.IntroPage;
import io.newgrounds.test.ui.MainScreen;
import io.newgrounds.test.ui.Input;

import openfl.display.Sprite;

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