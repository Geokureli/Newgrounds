package io.newgrounds.components.loader;

/**
 * This class handles loading various URLs and tracking referral stats.
 *
 * Note: These calls do not return any JSON packets (unless the redirect param is set to false).
 * Instead, they redirect to the appropriate URL. These calls should be executed in a browser
 * window vs using AJAX or any other internal loaders.
 */
class LoaderComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function loadAuthorUrl(redirect = false) {
		
		return new Call<UrlData>(_core, "Loader.loadAuthorUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadMoreGames(redirect = false) {
		
		return new Call<UrlData>(_core, "Loader.loadMoreGames")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadNewgrounds(redirect = false) {
		
		return new Call<UrlData>(_core, "Loader.loadNewgrounds")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadOfficialUrl(redirect = false) {
		
		return new Call<UrlData>(_core, "Loader.loadOfficialUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadReferral(redirect = false) {
		
		return new Call<UrlData>(_core, "Loader.loadReferral")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
}