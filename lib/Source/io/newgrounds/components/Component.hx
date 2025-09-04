package io.newgrounds.components;

import io.newgrounds.objects.AppData;
import io.newgrounds.objects.events.BaseResultData;
import io.newgrounds.utils.Logger;

class Component {
	
	final core:BaseCore;
	
	public function new(core:BaseCore) {
		
		this.core = core;
	}
	
	function makeCall<T:BaseResultData>(component:String, requireSession = false, isSecure = false):Call<T> {
		
		return core.callList.add(new Call<T>(core.appData, core.logger, component, requireSession, isSecure));
	}
}