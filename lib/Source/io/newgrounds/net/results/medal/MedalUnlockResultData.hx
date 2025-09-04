package io.newgrounds.net.results.medal;

import io.newgrounds.net.data.MedalData;
import io.newgrounds.net.results.BaseResultData;

@:noCompletion
typedef RawMedalUnlockResultData = BaseResultData & {
	
	final medal_score:String;
	final medal:MedalData;
}

@:forward
abstract MedalUnlockResultData(RawMedalUnlockResultData) from RawMedalUnlockResultData to BaseResultData {
	
	/** The user's new medal score. */
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
	var medal_score(get, never):String;
	inline function get_medal_score() return this.medal_score;
}
