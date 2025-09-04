package io.newgrounds.net.results.score;

import io.newgrounds.net.data.Period;
import io.newgrounds.net.data.Score;
import io.newgrounds.net.data.ScoreBoardData;
import io.newgrounds.net.data.User;
import io.newgrounds.net.results.BaseResultData;

typedef RawGetScoresResultData = ExternalAppResultData & BaseResultData & {
	
	/* An array of Score objects. */
	var scores    (default, null):Array<Score>;
	
	/* The ScoreBoard being queried. */
	var scoreboard(default, null):ScoreBoardData;
	
	/* The query skip that was used. */
	var limit(default, null):Int;
	
	/* The time-frame the scores belong to. See notes for acceptable values. */
	var period(default, null):Period;
	
	/*
	 * Will return true if scores were loaded in social context ('social' set to true and a
	 * session or 'user' were provided).
	**/
	var social(default, null):Bool;
	
	/*
	 * The user the score list is associated with (either as defined in the 'user' param, or
	 * extracted from the current session when 'social' is set to true)
	**/
	var user(default, null):User;
}

@:forward
abstract GetScoresResultData(RawGetScoresResultData) from RawGetScoresResultData to BaseResultData {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}