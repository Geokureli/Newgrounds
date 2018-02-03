package io.newgrounds.test.ui;

import openfl.events.MouseEvent;
import openfl.display.MovieClip;

class Button {
	
	@:isVar
	public var enabled(default, set):Bool;
	function set_enabled(value:Bool):Bool {
		
		if (value != this.enabled) {
			
			this.enabled = value;
			updateState(); 
		}
		
		return value;
	}
	
	public var onClick:Void->Void;
	public var onOver:Void->Void;
	public var onOut:Void->Void;
	
	var _target:MovieClip;
	var _down:Bool;
	var _over:Bool;
	var _foundLabels:Array<String>;
	
	public function new(target:MovieClip, onClick:Void->Void, onOver:Void->Void = null, onOut:Void->Void = null) {
		
		_target = target;
		this.onClick = onClick;
		this.onOver = onOver;
		this.onOut = onOut;
		
		_foundLabels = new Array<String>();
		for (label in _target.currentLabels)
			_foundLabels.push(label.name);
		
		_target.stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		_target.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		_target.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		_target.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		_target.addEventListener(MouseEvent.CLICK, mouseHandler);
		
		_target.useHandCursor = true;
		_target.buttonMode = true;
		_target.stop();
		
		enabled = true;
	}
	
	function mouseHandler(event:MouseEvent):Void {
		
		switch(event.type) {
			
			case MouseEvent.MOUSE_OVER:
				
				_over = true;
				
				if (onOver != null)
					onOver();
				
			case MouseEvent.MOUSE_OUT:
				
				_over = false;
				
				if (onOver != null)
					onOver();
				
			case MouseEvent.MOUSE_DOWN:
				
				_down = true;
				
			case MouseEvent.MOUSE_UP:
				
				_down = false;
				
			case MouseEvent.CLICK:
				
				if (enabled && onClick != null)
					onClick();
		}
		updateState();
	}
	
	function updateState():Void {
		
		var state:String;
		if (enabled) {
			
			if (_over)
				state = _down ? "down" : "over";
			else
				state = "up";
			
		} else
			state = "disabled";
		
		if (_target.currentLabel != state && _foundLabels.indexOf(state) != -1)
			_target.gotoAndStop(state);
	}
	
	public function destroy():Void {
		
		_target.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		_target.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		_target.removeEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		_target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		_target.removeEventListener(MouseEvent.CLICK, mouseHandler);
		
		_target = null;
		onClick = null;
		onOver = null;
		onOut = null;
		_foundLabels = null;
	}
	
	static public function caster(onClick:Void->Void):MovieClip->Button {
		
		return function (target:MovieClip):Button {
			
			return new Button(target, onClick);
		}
	}
}
