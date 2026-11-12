package io.newgrounds;

import io.newgrounds.debug.Logger;
import io.newgrounds.net.CallList;
import io.newgrounds.net.data.AppData;

@:nullSafety(Strict)
class BaseCore {
	
	public final appData:AppData;
	
	public final logger:Logger;
	
	@:allow(io.newgrounds.components.Component)
	final callList = new CallList();
	
	/** The name of the host the game is being played on */
	public var host:Null<String>;
	
	public function new(app:AppData, logger) {
		
		appData = app;
		
		this.logger = logger;
	}
}