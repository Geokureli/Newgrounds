package io.newgrounds.test.ui;

import openfl.events.Event;
import openfl.text.TextField;

class Input {
	
	public var text(get, set):String;
	function get_text():String { return _target.text; }
	function set_text(value:String):String { return _target.text = value; }
	
	var _target:TextField;
	var _onChange:String->Void;
	
	public function new(target:TextField, onChange:String->Void) {
		
		_target = target;
		_onChange = onChange;
		
		_target.addEventListener(Event.CHANGE, handleChange);
	}
	
	function handleChange(e:Event):Void {
		
		_onChange(_target.text);
	}
}
