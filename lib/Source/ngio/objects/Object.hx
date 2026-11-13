package ngio.objects;

import ngio.cores.CallableCore;
import ngio.events.Dispatcher;

class CoreObject<T> extends Object<T>
{
	var _core:CallableCore;
	
	public function new(core, data:T = null)
	{
		_core = core;
		super(data);
	}
	
	override function destroy()
	{
		super.destroy();
		_core = null;
	}
}

class Object<T>
{
	var _data:T;
	
	public final onUpdate = new Dispatcher();
	
	public function new(data:T = null) {
		
		if (data != null)
			parse(data);
	}
	
	public function parse(data:T)
	{
		_data = data;
		onUpdate.dispatch();
	}
	
	public function destroy()
	{
		onUpdate.clear();
	}
}