package ngio.components;

import ngio.net.Call;
import ngio.net.results.loader.*;

/**
 * This class handles loading various URLs and tracking referral stats.
 *
 * Note: These calls do not return any JSON packets (unless the redirect param is set to false).
 * Instead, they redirect to the appropriate URL. These calls should be executed in a browser
 * window vs using AJAX or any other internal loaders.
 */
class LoaderComponent extends Component
{
	public function loadAuthorUrl(redirect = false)
	{
		return (makeCall("Loader.loadAuthorUrl"): Call<UrlResultData>)
			.addComponentParameter("host", core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadMoreGames(redirect = false)
	{
		return (makeCall("Loader.loadMoreGames"): Call<UrlResultData>)
			.addComponentParameter("host", core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadNewgrounds(redirect = false)
	{
		return (makeCall("Loader.loadNewgrounds"): Call<UrlResultData>)
			.addComponentParameter("host", core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadOfficialUrl(redirect = false)
	{
		return (makeCall("Loader.loadOfficialUrl"): Call<UrlResultData>)
			.addComponentParameter("host", core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadReferral(redirect = false)
	{
		return (makeCall("Loader.loadReferral"): Call<UrlResultData>)
			.addComponentParameter("host", core.host)
			.addComponentParameter("redirect", redirect, true);
	}
}