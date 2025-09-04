package io.newgrounds.net.results.medal;

import io.newgrounds.net.results.BaseResultData;

typedef RawMedalScoreData = BaseResultData & {
	
	final medal_score:Int;
}

@:forward
abstract MedalScoreResultData(RawMedalScoreData) from RawMedalScoreData to BaseResultData {
	
	/** The user's medal score. */
	public var medalScore(get, never):Int;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	var medal_score(get, never):Int;
	inline function get_medal_score() return this.medal_score;
}
