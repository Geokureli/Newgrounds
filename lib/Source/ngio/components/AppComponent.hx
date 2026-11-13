package ngio.components;

import ngio.net.Call;
import ngio.net.results.BaseResultData;
import ngio.net.results.SessionResultData;
import ngio.net.results.app.*;

class AppComponent extends Component
{
	public function startSession(force = false)
	{
		return (makeCall("App.startSession"): Call<SessionResultData>)
			.addComponentParameter("force", force, false);
	}
	
	public function checkSession()
	{
		return (makeCall("App.checkSession", true): Call<SessionResultData>);
	}
	
	public function endSession()
	{
		return (makeCall("App.endSession", true): Call<SessionResultData>);
	}
	
	public function getCurrentVersion(version:String)
	{
		return (makeCall("App.getCurrentVersion"): Call<GetCurrentVersionResultData>)
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense()
	{
		return (makeCall("App.getHostLicense"): Call<GetHostResultData>)
			.addComponentParameter("host", core.host);
	}
	
	public function logView()
	{
		return (makeCall("App.logView"): Call<BaseResultData>)
			.addComponentParameter("host", core.host);
	}
}