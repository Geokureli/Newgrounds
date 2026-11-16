package ngio.components;

import ngio.cores.BaseCore;
import ngio.data.AppData;
import ngio.debug.Logger;
import ngio.net.Call;
import ngio.net.results.BaseResultData;

class Component
{
	final core:BaseCore;
	
	public function new(core:BaseCore)
	{
		this.core = core;
	}
	
	function makeCall<T:BaseResultData>(component:String, requireSession = false, isSecure = false):Call<T>
	{
		return core.callList.add(new Call<T>(core.appData, core.logger, component, requireSession, isSecure));
	}
}