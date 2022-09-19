package io.newgrounds.components;

import io.newgrounds.objects.Medal;
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
		
		return new Call<MedalListResult>(_core, "Medal.getList")
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Fetches the user's current medal score.
	**/
	public function getMedalScore():Call<MedalScoreResult> {
		
		return new Call<MedalScoreResult>(_core, "Medal.getMedalScore");
	}
}


typedef RawMedalScoreResult = ResultBase
	& { medal_score:Int }
@:forward
abstract MedalScoreResult(RawMedalScoreResult) from RawMedalScoreResult to ResultBase {
	
	/** The user's medal score. */
	public var medalScore(get, never):Int;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	var medal_score(get, never):Int;
	inline function get_medal_score() return this.medal_score;
}