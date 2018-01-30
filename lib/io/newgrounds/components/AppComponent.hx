package io.newgrounds.components;

import io.newgrounds.NGLite;

class AppComponent extends Component {
	
	public function new (core:NGLite) { super(core); }
	
	public function startSession(force:Bool = false):Call {
		
		return new Call(_core, "App.startSession")
			.addComponentParameter("force", force, false);
	}
	
	public function checkSession():Call {
		
		return new Call(_core, "App.checkSession", true);
	}
	
	public function endSession():Call {
		
		return new Call(_core, "App.endSession", true);
	}
	
	public function getCurrentVersion(version:String):Call {
	
		return new Call(_core, "App.getCurrentVersion")
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense(host:String):Call {
		
		return new Call(_core, "App.getHostLicense")
			.addComponentParameter("host", host);
	}
	
	public function logView(host:String):Call {
	
		return new Call(_core, "App.logView")
			.addComponentParameter("host", host);
	}
}