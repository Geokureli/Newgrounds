package ngio.net.results.score;

import ngio.data.PeriodData;
import ngio.data.ScoreBoardData;
import ngio.data.ScoreData;
import ngio.data.UserData;
import ngio.net.results.BaseResultData;

typedef RawGetScoresResultData = ExternalAppResultData & BaseResultData &
{
	/* An array of Score objects. */
	final scores    :Array<ScoreData>;
	
	/* The ScoreBoard being queried. */
	final scoreboard:ScoreBoardData;
	
	/* The query skip that was used. */
	final limit:Int;
	
	/* The time-frame the scores belong to. See notes for acceptable values. */
	final period:PeriodData;
	
	/*
	 * Will return true if scores were loaded in social context ('social' set to true and a
	 * session or 'user' were provided).
	**/
	final social:Bool;
	
	/*
	 * The user the score list is associated with (either as defined in the 'user' param, or
	 * extracted from the current session when 'social' is set to true)
	**/
	final user:UserData;
}

@:forward
abstract GetScoresResultData(RawGetScoresResultData) from RawGetScoresResultData to BaseResultData
{
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}