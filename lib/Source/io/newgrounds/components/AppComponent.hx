package io.newgrounds.components;

import io.newgrounds.net.Call;
import io.newgrounds.net.results.BaseResultData;
import io.newgrounds.net.results.SessionResultData;
import io.newgrounds.net.results.app.*;

class AppComponent extends Component {
	
	public function new (core) { super(core); }
	
	public function startSession(force = false) {
		
		return (makeCall("App.startSession"): Call<SessionResultData>)
			.addComponentParameter("force", force, false);
	}
	
	public function checkSession() {
		
		return (makeCall("App.checkSession", true): Call<SessionResultData>);
	}
	
	public function endSession() {
		
		return (makeCall("App.endSession", true): Call<SessionResultData>);
	}
	
	public function getCurrentVersion(version:String) {
	
		return (makeCall("App.getCurrentVersion"): Call<GetCurrentVersionResultData>)
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense() {
		
		return (makeCall("App.getHostLicense"): Call<GetHostResultData>)
			.addComponentParameter("host", core.host);
	}
	
	public function logView() {
		
		return (makeCall("App.logView"): Call<BaseResultData>)
			.addComponentParameter("host", core.host);
	}
}