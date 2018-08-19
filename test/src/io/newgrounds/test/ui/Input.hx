package io.newgrounds.test.ui;

import openfl.events.TextEvent;
import openfl.events.Event;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldType;

class Input {
	
	public var text(get, set):String;
	function get_text():String { return _target.text; }
	function set_text(value:String):String { return _target.text = value; }
	
	public var trimMethod:String->String;
	
	var _target:TextField;
	var _onChange:String->Void;
	
	public function new(target:TextField, onChange:String->Void, trimMethod:String->String = null) {
		
		_target = target;
		_onChange = onChange;
		this.trimMethod = trimMethod;
		
		_target.addEventListener(Event.CHANGE, handleChange);
		// TODO: track focus events to reduce calls
		
		trim();
	}
	
	function handleChange(e:Event):Void {
		
		trim();
		
		_onChange(_target.text);
	}
	
	inline function trim():Void {
		
		if (trimMethod != null) {
			
			_target.removeEventListener(Event.CHANGE, handleChange);
			_target.text = trimEndWhitespace(_target.text);
			_target.addEventListener(Event.CHANGE, handleChange);
		}
	} 
	
	static var whitespaceRemover:EReg = ~/^\s*(.*?)\s*$/;
	static public function trimEndWhitespace(value:String):String {
		
		if (whitespaceRemover.match(value))
			return whitespaceRemover.matched(1);
		
		return value;
	}
	
	inline static public function mouseDisableText(parent:DisplayObjectContainer):Void {
		
		var i = parent.numChildren;
		
		while(i > 0) {
			i--;
			
			var child = parent.getChildAt(i);
			if (Std.is(child, TextField)) {
				
				var field:TextField = cast child;
				if (field.type == TextFieldType.DYNAMIC)
					field.mouseEnabled = field.selectable;
			}
		}
	}
}
