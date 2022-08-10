package io.newgrounds.test;

#if !simple
import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.IntroPage;
import io.newgrounds.test.ui.MainScreen;
#end

import openfl.display.Sprite;

class Main extends Sprite {
	
	public function new() {
		super();
		
		#if simple
		// A barebones test with no flashy UI
		new SimpleTest();
		#else
		// A flashy UI to showcase all the features
		var page = new IntroScreenSwf();
		addChild(page);
		
		new IntroPage(page,
			function onStart():Void {
				
				removeChild(page);
				page = null;
				
				addChild(new MainScreen());
			}
		);
		#end
	}
}