package io.newgrounds.test.ui;

import io.newgrounds.swf.common.Button;
import io.newgrounds.test.art.RadioButtonSwf;

import openfl.display.MovieClip;

class RadioButton extends Button {
	
	public var parentEnabled(default, set):Bool;
	function set_parentEnabled(value:Bool):Bool {
		
		if (this.parentEnabled != value) {
			
			this.parentEnabled = value;
			updateEnabled();
		}
		
		return value;
	}

	override function get_enabled():Bool { 
		
		return _enabled && parentEnabled;
	}
	
	public var name(get, never):String;
	function get_name():String { return _target.name; };
	
	public var selected(default, set):Bool;
	public function set_selected(value:Bool):Bool {
		
		_dot.visible = value;
		return this.selected = value;
	}
	
	var _dot:MovieClip;
	
	public function new(target:RadioButtonSwf, onClick:Void->Void) {
		_dot = target.dot;
		
		super(target, onClick);
		
		selected = false;
	}
	
	override function updateState():Void {
		super.updateState();
		
		_dot.alpha = parentEnabled ? 1.0 : 0.5;
	}
	
	override function determineState():String {
		
		if (selected && parentEnabled)
			return "up";
		
		return super.determineState();
	}
}
