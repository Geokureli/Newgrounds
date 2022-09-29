package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

/**
 * This class handles loading various URLs and tracking referral stats.
 *
 * Note: These calls do not return any JSON packets (unless the redirect param is set to false).
 * Instead, they redirect to the appropriate URL. These calls should be executed in a browser
 * window vs using AJAX or any other internal loaders.
 */
class LoaderComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function loadAuthorUrl(redirect = false):Call<UrlData> {
		
		return new Call<UrlData>(_core, "Loader.loadAuthorUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadMoreGames(redirect = false):Call<UrlData> {
		
		return new Call<UrlData>(_core, "Loader.loadMoreGames")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadNewgrounds(redirect = false):Call<UrlData> {
		
		return new Call<UrlData>(_core, "Loader.loadNewgrounds")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadOfficialUrl(redirect = false):Call<UrlData> {
		
		return new Call<UrlData>(_core, "Loader.loadOfficialUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadReferral(referralName:String, logStat = true, redirect = false):Call<UrlData> {
		
		return new Call<UrlData>(_core, "Loader.loadReferral")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("referral_name", referralName)
			.addComponentParameter("log_stat", logStat, true)
			.addComponentParameter("redirect", redirect, true);
	}
}

typedef UrlData = BaseData & {
	
	// TODO: docs
	var url:String;
}