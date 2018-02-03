package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class LoaderComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function loadAuthorUrl(redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadAuthorUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadMoreGames(redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadMoreGames")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadNewgrounds(redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadNewgrounds")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadOfficialUrl(redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadOfficialUrl")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadReferral(redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadReferral")
			.addComponentParameter("host", _core.host)
			.addComponentParameter("redirect", redirect);
	}
}