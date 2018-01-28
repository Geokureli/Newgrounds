package io.newgrounds.objects;

import io.newgrounds.NG;

class Object {
	
	var _core:NG;
	
	public function new(core:NG, data:Dynamic = null) {
		
		this._core = core; 
		
		if (data != null)
			parse(data);
	}
	
	function parse(data:Dynamic):Void { }
	
	public function destroy():Void {
		
		_core = null;
	}
}