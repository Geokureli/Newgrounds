package io.newgrounds.test.swf;

import io.newgrounds.test.ui.Input;
import io.newgrounds.test.ui.CheckBox;
import io.newgrounds.swf.common.DropDown;
import openfl.display.MovieClip;
import openfl.text.TextField;

import io.newgrounds.swf.ScoreBrowser;

class ScoreBrowserSlim extends ScoreBrowser {
	
	public var tagField:TextField;
	public var socialBox:MovieClip;
	public var nameListBox:MovieClip;
	
	var _social:CheckBox;
	var _nameDropDown:DropDown;
	
	public function new() { super(); }
	
	override function setDefaults():Void {
		super.setDefaults();
		
		titleField.visible = false;
		
		_social = new CheckBox(socialBox, onSocialToggle);
		new Input(tagField, onTagChange, Input.trimEndWhitespace);
		
		_nameDropDown = new DropDown(nameListBox, onBoardChange);
		_nameDropDown.addItem("Loading", "Loading");
		_nameDropDown.value = "Loading";
		_nameDropDown.enabled = false;
	}
	
	override function onBoardsLoaded() {
		
		_nameDropDown.enabled = true;
		
		var first = true;
		for (board in NG.core.scoreBoards) {
			
			if (first)
				_nameDropDown.editItem("Loading", board.name, Std.string(board.id));
			else
				_nameDropDown.addItem(board.name, Std.string(board.id));
			
			first = false;
		}
		
		super.onBoardsLoaded();
	}
	
	function onBoardChange() {
		
		if (_nameDropDown.value != "Loading") {
			
			boardId = Std.parseInt(_nameDropDown.value);
		}
	}
	
	function onSocialToggle():Void {
		
		social = _social.on;
	}
	
	function onTagChange(value:String):Void {
		
		tag = value;
	}
}
