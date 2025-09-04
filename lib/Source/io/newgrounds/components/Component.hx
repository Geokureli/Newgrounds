package io.newgrounds.components;

import io.newgrounds.debug.Logger;
import io.newgrounds.net.Call;
import io.newgrounds.net.data.AppData;
import io.newgrounds.net.results.BaseResultData;

class Component {
	
	final core:BaseCore;
	
	public function new(core:BaseCore) {
		
		this.core = core;
	}
	
	function makeCall<T:BaseResultData>(component:String, requireSession = false, isSecure = false):Call<T> {
		
		return core.callList.add(new Call<T>(core.appData, core.logger, component, requireSession, isSecure));
	}
}