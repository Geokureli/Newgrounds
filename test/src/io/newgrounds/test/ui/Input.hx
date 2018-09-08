package io.newgrounds.test.ui;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.TextField;
#if flash
	import openfl.geom.Matrix;
	import openfl.display.GradientType;
	import openfl.display.Shape;
#else
	import openfl.text.TextFieldType;
#end
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
	
	#if !flash
	/**
	 * In HTML5 non-selectable static text blocks mouse input, where this is not the case in Flash
	 * 
	 * @param parent The container of one or many TextFields to mouse-disable
	 */
	static public function mouseDisableText(parent:DisplayObjectContainer):Void {
		
		var i = parent.numChildren;
		
		while(i > 0) {
			i--;
			
			var child = parent.getChildAt(i);
			if (Std.is(child, TextField)) {
				
				if (cast(child, TextField).type == TextFieldType.DYNAMIC)
					cast(child, TextField).mouseEnabled = cast(child, TextField).selectable;
			}
		}
	}
	#end
	
	/**
	 * Since animate can only 
	 * 
	 * @param parent The container of input TextFields to colorise.
	 */
	static public function drawInputBg(parent:DisplayObjectContainer):Void {
		
		var child;
		var field;
		var shape;
		var matrix;
		var bounds;
		
		var i = 0;
		while(i < parent.numChildren) {
			
			child = parent.getChildAt(i);
			if (Std.is(child, TextField)) {
				
				field = cast (child, TextField);
				if (field.background) {
					
					#if flash
						// gradient box mode
						field.background = false;
						field.border = false;
						
						shape = new Shape();
						shape.graphics.lineStyle(1, 0x585858);
						matrix = new Matrix();
						matrix.createGradientBox(field.width, 20, Math.PI * 0.5, field.x, field.y);
						shape.graphics.beginGradientFill
							( GradientType.LINEAR
							, [0xFFFFFF, 0x667884, 0xA3B2B9, 0x808080]
							, [1.0     , 1.0     , 1.0     , 1.0     ]
							, [0       , 1       , 0xFE    , 0xFF    ]
							, matrix
							);
						
						shape.graphics.drawRect(field.x, field.y, field.width, field.height);
						shape.graphics.endFill();
						parent.addChildAt(shape, i);
						i++;
					#else
						// html gradients suck
						field.backgroundColor = 0xA3B2B9;
						field.borderColor = 0x585858;
					#end
				}
			}
			
			i++;
		}
	}
}
