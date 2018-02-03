package io.newgrounds.test.utils;

import openfl.text.TextField;
import openfl.display.MovieClip;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

class SwfUtils {
	
	@:generic
	inline static public function get<T:DisplayObject>(parent:DisplayObjectContainer, path:String):T {
		
		return aGet(parent, path.split("."));
	}
	
	@:generic
	inline static public function aGet<T:DisplayObject>(parent:DisplayObjectContainer, path:Array<String>):T {
		
		var child:DisplayObject = null;
		while (path.length > 0) {
			
			child = parent.getChildByName(path.shift());
			if (Std.is(child, DisplayObjectContainer))
				parent = cast child;
		}
		
		return cast child;
	}
	
	inline static public function getMc(parent:DisplayObjectContainer, path:String):MovieClip {
		
		return get(parent, path);
	}
	
	inline static public function getField(parent:DisplayObjectContainer, path:String):TextField {
		
		return get(parent, path);
	}
}
