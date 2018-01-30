package;

import io.newgrounds.test.Test;
import io.newgrounds.NG;

import openfl.display.Sprite;

class Main extends Sprite {
	
	var _currentTest:Test;
	
	public function new () {
		
		super ();
		
		NG.createCore();
		NG.core.verbose = true;
		
		NG.core.requestLogin(onLogin);
	}
	
	function onLogin():Void {
		
		trace("logged in");
		
		NG.core.loadMedals(showMedals);
	}
	
	function showMedals():Void {
		
		
	}
}