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
	public function unlock(id:Int):Call<MedalUnlockResult> {
		
		return new Call<MedalUnlockResult>(_core, "Medal.unlock", true, true)
			.addComponentParameter("id", id);
	}
	
	/**
	 * Fetches a list of Medal objects.
	 * 
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function getList(externalAppId:String = null):Call<MedalListResult> {
		
		return new Call<MedalListResult>(_core, "Medal.getList");
	}
	
	/**
	 * Fetches the user's current medal score.
	**/
	public function getMedalScore():Call<MedalScoreResult> {
		
		return new Call<MedalScoreResult>(_core, "Medal.getMedalScore");
	}
}