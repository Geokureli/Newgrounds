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
	
	public function loadAuthorUrl(redirect:Bool = false):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadAuthorUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadMoreGames(redirect:Bool = false):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadMoreGames")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadNewgrounds(redirect:Bool = false):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadNewgrounds")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadOfficialUrl(redirect:Bool = false):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadOfficialUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
	
	public function loadReferral(redirect:Bool = false):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadReferral")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect, true);
	}
}