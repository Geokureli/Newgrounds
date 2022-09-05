package io.newgrounds.swf.common;

import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.text.TextField;

class Button {
	
	var _enabled:Bool;
	public var enabled(get, set):Bool;
	function get_enabled():Bool return _enabled;
	function set_enabled(value:Bool):Bool {
		
		if (value != _enabled) {
			
			_enabled = value;
			updateEnabled();
		}
		
		return value;
	}
	
	public var visible(get, set):Bool;
	inline function get_visible():Bool return _target.visible;
	inline function set_visible(value:Bool):Bool return _target.visible = value;
	
	public var onClick:Void->Void;
	public var onOver:Void->Void;
	public var onOut:Void->Void;
	
	var _target:MovieClip;
	var _hitbox:DisplayObject;
	var _down:Bool;
	var _over:Bool;
	var _foundLabels:Array<String>;
	
	public function new(target:MovieClip, onClick:Void->Void = null, onOver:Void->Void = null, onOut:Void->Void = null) {
		
		_target = target;
		this.onClick = onClick;
		this.onOver = onOver;
		this.onOut = onOut;
		
		_hitbox = _target.getChildByName("hitbox");
		if (_hitbox == null)
			_hitbox = _target;
		
		_foundLabels = new Array<String>();
		for (label in _target.currentLabels)
			_foundLabels.push(label.name);
		
		_target.stop();
		_target.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		if (target.stage != null)
			onAdded(null);
		
		enabled = true;
	}
	
	public function setLabel(label:String) {
		
		var field:TextField = cast _target.getChildByName("label");
		if (field == null)
			throw 'Missing expected child: "label"';
		
		field.text = label;
	}
	
	function onAdded(e:Event):Void {
		
		var stage = _target.stage;
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		_hitbox.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		_hitbox.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		_hitbox.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		_hitbox.addEventListener(MouseEvent.CLICK, mouseHandler);
		
		function selfRemoveEvent(e:Event):Void {
			
			_target.removeEventListener(Event.REMOVED_FROM_STAGE, selfRemoveEvent);
			onRemove(e, stage);
		}
		_target.addEventListener(Event.REMOVED_FROM_STAGE, selfRemoveEvent);
	}
	
	function onRemove(e:Event, stage:Stage):Void {
		
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		_hitbox.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		_hitbox.removeEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		_hitbox.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		_hitbox.removeEventListener(MouseEvent.CLICK, mouseHandler);
	}
	
	function mouseHandler(event:MouseEvent):Void {
		
		switch(event.type) {
			
			case MouseEvent.MOUSE_OVER:
				
				_over = true;
				
				if (onOver != null)
					onOver();
				
			case MouseEvent.MOUSE_OUT:
				
				_over = false;
				
				if (onOut != null)
					onOut();
				
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
	
	function updateEnabled():Void {
		
		updateState();
		
		_target.useHandCursor = enabled;
		_target.buttonMode = enabled;
	}
	
	function updateState():Void {
		
		var state = determineState();
		
		if (_target.currentLabel != state && _foundLabels.indexOf(state) != -1)
			_target.gotoAndStop(state);
	}
	
	function determineState():String {
		
		if (enabled) {
			
			if (_over)
				return _down ? "down" : "over";
			
			return "up";
			
		}
		return "disabled";
	}
	
	public function destroy():Void {
		
		_target.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		_target = null;
		_hitbox = null;
		onClick = null;
		onOver = null;
		onOut = null;
		_foundLabels = null;
	}
}
