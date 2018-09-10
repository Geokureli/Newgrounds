package io.newgrounds.test.ui;

import io.newgrounds.swf.common.Button;
import openfl.display.MovieClip;

class CheckBox extends Button {
	
	@:isVar
	public var on(default, set):Bool;
	function set_on(value:Bool):Bool {
		
		this.on = value;
		updateState();
		
		return value;
	}
	
	public var onToggle:Void->Void;
	
	var _check:MovieClip;
	
	public function new(target:MovieClip, onToggle:Void->Void = null, onOver:Void->Void = null, onOut:Void->Void = null) {
		
		this.onToggle = onToggle;
		_check = cast target.getChildByName("check");
		
		super(target, handleClick, onOver, onOut);
	}
	
	function handleClick():Void {
		
		on = !on;
		if (onToggle != null)
			onToggle();
	}

	override function updateState():Void {
		
		_check.visible = on;
	}
}
