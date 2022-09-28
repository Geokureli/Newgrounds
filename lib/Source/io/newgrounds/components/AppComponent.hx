package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class AppComponent extends Component {
	
	public function new (core:NGLite) { super(core); }
	
	public function startSession(force:Bool = false):Call<SessionData> {
		
		return new Call<SessionData>(_core, "App.startSession")
			.addComponentParameter("force", force, false);
	}
	
	public function checkSession():Call<SessionData> {
		
		return new Call<SessionData>(_core, "App.checkSession", true);
	}
	
	public function endSession():Call<SessionData> {
		
		return new Call<SessionData>(_core, "App.endSession", true);
	}
	
	public function getCurrentVersion(version:String):Call<GetCurrentVersionData> {
	
		return new Call<GetCurrentVersionData>(_core, "App.getCurrentVersion")
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense():Call<GetHostData> {
		
		return new Call<GetHostData>(_core, "App.getHostLicense")
			.addComponentParameter("host", _core.host);
	}
	
	public function logView():Call<BaseData> {
		
		return new Call<BaseData>(_core, "App.logView")
			.addComponentParameter("host", _core.host);
	}
}