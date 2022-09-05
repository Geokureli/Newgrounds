package io.newgrounds.swf.common;


import haxe.ds.StringMap;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;

class DropDown {
	
	public var value(default, set):String;
	function set_value(v:String):String {
		
		if (this.value == v)
			return v;
		
		this.value = v;
		_selectedLabel.text = _values.get(v);
		
		if (_onChange != null)
			_onChange();
		
		return v;
	}
	
	public var enabled(get, set):Bool;
	inline function get_enabled():Bool return _expandButton.enabled;
	function set_enabled(v:Bool):Bool {
		
		_expandButton.enabled = v;
		_currentItemButton.enabled = v;
		
		return v;
	}
	
	var _choiceContainer:Sprite;
	var _selectedLabel:TextField;
	var _onChange:Void->Void;
	var _values:Map<String, String>;
	var _unusedChoices:Array<MovieClip>;
	var _choices:Map<String, Button>;
	var _expandButton:Button;
	var _currentItemButton:Button;
	
	public function new(target:MovieClip, label:String = "", onChange:Void->Void = null) {
		
		_onChange = onChange;
		
		_selectedLabel = cast cast(target.getChildByName("currentItem"), MovieClip).getChildByName("label");
		_selectedLabel.text = label;
		
		_values = new Map();
		_choices = new Map();
		
		_expandButton = new Button(cast target.getChildByName("button"), onClickExpand);
		_currentItemButton = new Button(cast target.getChildByName("currentItem"), onClickExpand);
		_choiceContainer = new Sprite();
		_choiceContainer.visible = false;
		target.addChild(_choiceContainer);
		
		_unusedChoices = new Array<MovieClip>();
		while(true) {
			
			var item:MovieClip = cast target.getChildByName('item${_unusedChoices.length}');
			if (item == null)
				break;
			
			target.removeChild(item);
			_unusedChoices.push(item);
		}
	}
	
	public function addItem(name:String, value:String):Void {
		
		_values.set(value, name);
		
		if (_unusedChoices.length == 0) {
			
			NG.core.logError('cannot create another dropBox item max=${_choiceContainer.numChildren}');
			return;
		}
		
		var button = _unusedChoices.shift();
		_choiceContainer.addChild(button);
		
		_choices[name] = new Button(button, onChoiceClick.bind(value));
		_choices[name].setLabel(name);
	}
	
	public function editItem(oldName:String, newName:String, newValue:String) {
		
		if (_choices.exists(oldName) == false)
			throw 'could not find button: $oldName';
		
		var button = _choices[oldName];
		_choices.remove(oldName);
		_choices[newName] = button;
		button.setLabel(newName);
		button.onClick = onChoiceClick.bind(newValue);
		
		var oldValue:String = null;
		for (value in _values) {
			
			if (_values[value] == oldName)
				oldValue = value;
		}
		
		_values[newName] = newValue;
		
		// reselect choice
		if (this.value == oldValue) {
			
			@:bypassAccessor
			this.value = newValue;
			
			_selectedLabel.text = newName;
		}
	}
	
	function onClickExpand():Void {
		
		_choiceContainer.visible = !_choiceContainer.visible;
	}
	
	function onChoiceClick(name:String):Void {
		
		value = name;
		
		_choiceContainer.visible = false;
	}
}