package;

import io.newgrounds.test.ui.MainScreen;
import io.newgrounds.test.ui.Page.IntroPage;

import openfl.Assets;
import openfl.display.MovieClip;
import openfl.display.Sprite;

class Main extends Sprite {
	
	var _layout:MovieClip;
	
	public function new() {
		super();
		
		_layout = Assets.getMovieClip("layout:IntroScreen");
		addChild(_layout);
		
		new IntroPage(_layout, onStart);
	}
	
	function onStart():Void {
		
		removeChild(_layout);
		_layout = null;
		
		addChild(new MainScreen());
	}
}