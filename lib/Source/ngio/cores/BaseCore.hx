package ngio.cores;

import ngio.data.AppData;
import ngio.debug.Logger;
import ngio.net.CallList;

@:nullSafety(Strict)
class BaseCore {
	
	public final appData:AppData;
	
	public final logger:Logger;
	
	@:allow(ngio.components.Component)
	final callList = new CallList();
	
	/** The name of the host the game is being played on */
	public var host:Null<String>;
	
	public function new(app:AppData, logger) {
		
		appData = app;
		
		this.logger = logger;
	}
}