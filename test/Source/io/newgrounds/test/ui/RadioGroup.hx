package io.newgrounds.test.ui;

import haxe.ds.StringMap;
import io.newgrounds.test.art.RadioButtonSwf;

import openfl.display.MovieClip;

class RadioGroup {
	
	public var enabled(default, set):Bool;
	function set_enabled(value:Bool):Bool {
		
		if (value != this.enabled) {
			
			for (choice in _choices)
				choice.parentEnabled = value;
			
			this.enabled = value;
		}
		
		return value;
	}
	
	public var selected(default, set):String;
	function set_selected(value:String):String {
		
		if (selected != null){
			
			_choices.get(selected).selected = false;
			_choices.get(selected).enabled = true;
		}
		
		if (!_choices.exists(value))
			value = null;
		
		if (value != null) {
			
			_choices.get(value).selected = true;
			_choices.get(value).enabled = false;
		}
		
		this.selected = value;
		
		if (onChange != null)
			onChange();
		
		return this.selected;
	}
	
	public var onChange:Void->Void;
	
	var _choices:StringMap<RadioButton>;
	
	public function new(target:MovieClip, onChange:Void->Void = null) {
		
		this.onChange = onChange;
		_choices = new StringMap<RadioButton>();
		
		for (i in 0 ... target.numChildren) {
			
			var child = target.getChildAt(i);
			if (Std.is(child, RadioButtonSwf)) {
				
				var choice = new RadioButton(cast child, onSelect.bind(child.name));
				_choices.set(child.name, choice);
				choice.parentEnabled = true;
			}
		}
		
		enabled = true;
	}
	
	public function disableChoice(name:String):Void {
		
		_choices.get(name).enabled = false;
	}
	
	function onSelect(name:String):Void {
		
		selected = name;
	}
}
