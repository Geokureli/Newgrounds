package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.Call;
import io.newgrounds.NGLite;

class MedalComponent extends Component {
	
	public function new(core:NGLite):Void { super(core); }
	
	/**
	 * Unlocks a medal.
	 * 
	 * @param id  The numeric ID of the medal to unlock.
	**/
	public function unlock(id:Int):Call<MedalUnlockData> {
		
		return new Call<MedalUnlockData>(_core, "Medal.unlock", true, true)
			.addComponentParameter("id", id);
	}
	
	/**
	 * Fetches a list of Medal objects.
	 * 
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function getList(externalAppId:String = null):Call<MedalListData> {
		
		return new Call<MedalListData>(_core, "Medal.getList")
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Fetches the user's current medal score.
	**/
	public function getMedalScore():Call<MedalScoreData> {
		
		return new Call<MedalScoreData>(_core, "Medal.getMedalScore");
	}
}