package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class LoaderComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function loadAuthorUrl(host:String, redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadAuthorUrl")
			.addComponentParameter("host", host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadMoreGames(host:String, redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadMoreGames")
			.addComponentParameter("host", host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadNewgrounds(host:String, redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadNewgrounds")
			.addComponentParameter("host", host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadOfficialUrl(host:String, redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadOfficialUrl")
			.addComponentParameter("host", host)
			.addComponentParameter("redirect", redirect);
	}
	
	public function loadReferral(host:String, redirect:Bool = true):Call<ResultBase> {
		
		return new Call<ResultBase>(_core, "Loader.loadReferral")
			.addComponentParameter("host", host)
			.addComponentParameter("redirect", redirect);
	}
}