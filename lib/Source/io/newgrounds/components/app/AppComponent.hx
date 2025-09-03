package io.newgrounds.components.app;

import io.newgrounds.objects.events.BaseResultData;

class AppComponent extends Component {
	
	public function new (core) { super(core); }
	
	public function startSession(force:Bool = false):Call<SessionResultData> {
		
		return new Call<SessionResultData>(_core, "App.startSession")
			.addComponentParameter("force", force, false);
	}
	
	public function checkSession():Call<SessionResultData> {
		
		return new Call<SessionResultData>(_core, "App.checkSession", true);
	}
	
	public function endSession():Call<SessionResultData> {
		
		return new Call<SessionResultData>(_core, "App.endSession", true);
	}
	
	public function getCurrentVersion(version:String):Call<GetCurrentVersionData> {
	
		return new Call<GetCurrentVersionData>(_core, "App.getCurrentVersion")
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense():Call<GetHostData> {
		
		return new Call<GetHostData>(_core, "App.getHostLicense")
			.addComponentParameter("host", _core.host);
	}
	
	public function logView():Call<BaseResultData> {
		
		return new Call<BaseResultData>(_core, "App.logView")
			.addComponentParameter("host", _core.host);
	}
}