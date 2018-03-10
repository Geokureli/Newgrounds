package io.newgrounds.test.swf;

import io.newgrounds.test.ui.Input;
import io.newgrounds.test.ui.CheckBox;
import openfl.display.MovieClip;
import openfl.text.TextField;

import io.newgrounds.swf.ScoreBrowser;

class ScoreBrowserSlim extends ScoreBrowser {
	
	public var tagField:TextField;
	public var socialBox:MovieClip;
	
	var _social:CheckBox;
	
	public function new() {
		super();
		
		_social = new CheckBox(socialBox, onSocialToggle);
		new Input(tagField, onTagChange, Input.trimEndWhitespace);
	}
	
	function onSocialToggle():Void {
		
		social = _social.on;
	}
	
	function onTagChange(value:String):Void {
		
		tag = value;
	}
}
