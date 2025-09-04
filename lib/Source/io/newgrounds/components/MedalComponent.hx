package io.newgrounds.components;

import io.newgrounds.net.Call;
import io.newgrounds.net.results.medal.*;

class MedalComponent extends Component {
	
	public function new(core) { super(core); }
	
	/**
	 * Unlocks a medal.
	 * 
	 * @param id  The numeric ID of the medal to unlock.
	**/
	public function unlock(id:Int) {
		
		return (makeCall("Medal.unlock", true, true): Call<MedalUnlockResultData>)
			.addComponentParameter("id", id);
	}
	
	/**
	 * Fetches a list of Medal objects.
	 * 
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function getList(?externalAppId:String) {
		
		return (makeCall("Medal.getList"): Call<MedalListResultData>)
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Fetches the user's current medal score.
	**/
	public function getMedalScore() {
		
		return (makeCall("Medal.getMedalScore"): Call<MedalScoreResultData>);
	}
}

@:forward(getList)
abstract ExternalMedalComponent(MedalComponent) from MedalComponent {}