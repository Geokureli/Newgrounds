package io.newgrounds.test.ui;

import haxe.ds.StringMap;
import openfl.display.Sprite;
import openfl.text.TextField;
import io.newgrounds.test.art.DropDownItemSwf;
import io.newgrounds.test.art.DropDownSwf;

class DropDown {
	
	inline static var SPACING:Int = 20;
	
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
	
	var _choiceContainer:Sprite;
	var _button:Button;
	var _selectedLabel:TextField;
	var _onChange:Void->Void;
	var _values:StringMap<String>;
	
	public function new(target:DropDownSwf, label:String = "", onChange:Void->Void = null) {
		
		_onChange = onChange;
		
		_selectedLabel = target.label;
		_selectedLabel.text = label;
		
		_values = new StringMap<String>();
		
		_button = new Button(target.button, onClickExpand);
		_selectedLabel = target.label;
		_choiceContainer = new Sprite();
		//_choiceContainer.y = SPACING;
		_choiceContainer.visible = false;
		target.addChild(_choiceContainer);
	}
	
	public function addItem(name:String, value:String):Void {
		
		_values.set(value, name);
		
		var button = new DropDownItemSwf();
		button.label.text = name;
		button.y = (_choiceContainer.numChildren + 1) * -SPACING;
		_choiceContainer.addChild(button);
		
		new Button(button, onChoiceClick.bind(value));
	}
	
	function onClickExpand():Void {
		
		_choiceContainer.visible = true;
	}
	
	function onChoiceClick(name:String):Void{
		
		value = name;
		
		_choiceContainer.visible = false;
	} 
}
