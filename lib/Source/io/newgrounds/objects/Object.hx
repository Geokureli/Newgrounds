package io.newgrounds.objects;

import io.newgrounds.utils.Dispatcher;
import io.newgrounds.NGLite;

class Object<T> {
	
	var _core:NGLite;
	var _data:T;
	
	public var onUpdate(default, null):Dispatcher;
	
	public function new(core:NGLite, data:T = null) {
		
		this._core = core; 
		
		onUpdate = new Dispatcher();
		
		if (data != null)
			parse(data);
	}
	
	@:allow(io.newgrounds.NGLite)
	function parse(data:T):Void {
		
		_data = data;
		onUpdate.dispatch();
	}
	
	
	public function destroy():Void {
		
		_core = null;
	}
}