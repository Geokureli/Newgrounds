package;

import io.newgrounds.NG;

import openfl.display.Sprite;

class Main extends Sprite {
	
	public function new () {
		
		super ();
		
		NG.createCore("47215:Ip8uDj9v");
		NG.core.host = "localHost";
		NG.core.verbose = true;
		
		NG.core.requestLogin(onLogin);
	}
	
	function onLogin():Void {
		
		trace("logged in");
		
		NG.core.gateway.getDatetime()
			.addDataHandler(function(_):Void {})
			.send();
	}
}