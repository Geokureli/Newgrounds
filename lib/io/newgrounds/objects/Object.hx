package io.newgrounds.objects;

import io.newgrounds.NGLite;

class Object {
	
	var _core:NGLite;
	
	public function new(core:NGLite, data:Dynamic = null) {
		
		this._core = core; 
		
		if (data != null)
			parse(data);
	}
	
	@:allow(io.newgrounds.NGLite)
	function parse(data:Dynamic):Void { }
	
	public function destroy():Void {
		
		_core = null;
	}
}