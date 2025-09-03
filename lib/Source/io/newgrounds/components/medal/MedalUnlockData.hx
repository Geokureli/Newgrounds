package io.newgrounds.components.medal;

import io.newgrounds.objects.Medal;
import io.newgrounds.objects.events.BaseResultData;

@:noCompletion
typedef RawMedalUnlockData = BaseResultData
	& { medal_score:String, medal:RawMedalData }
    
@:forward
abstract MedalUnlockData(RawMedalUnlockData) from RawMedalUnlockData to BaseResultData {
	
	/** The user's new medal score. */
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	public var medal_score(get, never):String;
	@:deprecated("Use medalScore")
	inline function get_medal_score() return this.medal_score;
}
