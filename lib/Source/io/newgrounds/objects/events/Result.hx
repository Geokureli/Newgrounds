package io.newgrounds.objects.events;

import io.newgrounds.components.ScoreBoardComponent.Period;
import io.newgrounds.objects.Medal.RawMedalData;
import io.newgrounds.objects.ScoreBoard.RawScoreBoardData;
import io.newgrounds.objects.SaveSlot.RawSaveSlot;
import io.newgrounds.objects.User;

@:noCompletion
typedef RawResult<T:ResultBase> = {
	
	var component(default, null):String;
	var echo     (default, null):String;
	var data     (default, null):T;
}

abstract Result<T:ResultBase>(RawResult<T>) from RawResult<T> {
	
	public var component(get, never):String; inline function get_component() return this.component;
	public var echo     (get, never):String; inline function get_echo     () return this.echo;
	public var data     (get, never):T     ; inline function get_data     () return this.data;
	public var success  (get, never):Bool  ; inline function get_success  () return data.success;
	public var debug    (get, never):Bool  ; inline function get_debug    () return data.debug;
	public var error    (get, never):Error ; inline function get_error    () return data.error;
}

typedef ResultBase = {
	
	var success(default, null):Bool;
	var debug  (default, null):Bool;
	var error  (default, null):Error;
}

typedef SessionResult = ResultBase & {
	
	var session(default, null):Session;
}

typedef ResultExternalApp = {
	
	/** The App ID of another, approved app to load medals from. */
	var app_id(default, null):String;
}

@:noCompletion
typedef RawGetHostResult = ResultBase
	& { host_approved:Bool }
@:forward
abstract GetHostResult(RawGetHostResult) from RawGetHostResult to ResultBase {
	
	/** Wether the host is in the approved list. */
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
	
	/** Hidden, use currentVersion instead. */
	public var host_approved(get, never):Bool;
	@:deprecated("Use hostApproved")
	inline function get_host_approved() return this.host_approved;
}

@:noCompletion
typedef RawGetCurrentVersionResult = ResultBase
	& { current_version:String, client_deprecated:Bool }
@:forward
abstract GetCurrentVersionResult(RawGetCurrentVersionResult) from RawGetCurrentVersionResult to ResultBase {
	
	/** The version number of the app as defined in your "Version Control" settings. */
	public var currentVersion(get, never):String;
	inline function get_currentVersion() return this.current_version;
	
	/** Hidden, use currentVersion instead. */
	public var current_version(get, never):String;
	@:deprecated("Use currentVersion")
	inline function get_current_version() return this.current_version;
	
	/** Notes whether the client-side app is using a lower version number. */
	public var clientDeprecated(get, never):Bool;
	inline function get_clientDeprecated() return this.client_deprecated;
	
	/** Hidden, use clientDeprecated instead. */
	public var client_deprecated(get, never):Bool;
	@:deprecated("Use clientDeprecated")//depreception!
	inline function get_client_deprecated() return this.client_deprecated;
}

@:noCompletion
typedef RawLogEventResult = ResultBase
	& { event_name:String }
@:forward
abstract LogEventResult(RawLogEventResult) from RawLogEventResult to ResultBase {
	
	/** Hidden, use eventName instead . */
	public var event_name(get, never):String;
	@:deprecated("Use eventName")
	inline function get_event_name() return this.event_name;
	
	/** The event that was logged. */
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}

@:noCompletion
typedef RawGetDateTimeResult = ResultBase
	& { datetime:String }
@:forward
abstract GetDateTimeResult(RawGetDateTimeResult) from RawGetDateTimeResult to ResultBase {
	
	/** Hidden, use dateTime instead (capital T). */
	public var datetime(get, never):String;
	@:deprecated("datetime is deprecated, use dateTime (captial T)")
	inline function get_datetime() return this.datetime;
	
	/** The server's date and time in ISO 8601 format. */
	public var dateTime(get, never):String;
	inline function get_dateTime() return this.datetime;
}

typedef GetVersionResult = ResultBase & {
	
	/** The version number (in X.Y.Z format). */
	var version(default, null):String;
}

typedef PingResult = ResultBase & {
	
	/** Will always have a value of 'pong'. */
	var pong(default, null):String;
}

typedef RawMedalListResult = ResultExternalApp & ResultBase
	& { medals:Array<RawMedalData> }
@:forward
abstract MedalListResult(RawMedalListResult) from RawMedalListResult to ResultBase {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
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

@:noCompletion
typedef RawMedalUnlockResult = ResultBase
	& { medal_score:String, medal:RawMedalData }
@:forward
abstract MedalUnlockResult(RawMedalUnlockResult) from RawMedalUnlockResult to ResultBase {
	
	/** The user's new medal score. */
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	public var medal_score(get, never):String;
	@:deprecated("Use medalScore")
	inline function get_medal_score() return this.medal_score;
}

typedef GetBoardsResult = ResultBase & {
	
	/** An array of ScoreBoard objects. */
	var scoreboards(default, null):Array<RawScoreBoardData>;
}

typedef RawGetScoresResult = ResultExternalApp & ResultBase & {
	
	/* An array of Score objects. */
	var scores    (default, null):Array<Score>;
	
	/* The ScoreBoard being queried. */
	var scoreboard(default, null):RawScoreBoardData;
	
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
	 * The User the score list is associated with (either as defined in the 'user' param, or
	 * extracted from the current session when 'social' is set to true)
	**/
	var user(default, null):User;
}
@:forward
abstract GetScoresResult(RawGetScoresResult) from RawGetScoresResult to ResultBase {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}

typedef PostScoreResult = ResultBase & {
	
	/** The ScoreBoard that was posted to. */
	var scoreboard(default, null):RawScoreBoardData;
	/* The Score that was posted to the board. */
	var score     (default, null):Score;
}

typedef SaveSlotResult = ResultBase & {
	
	/** The save slot that was changed. */
	var slot(default, null):RawSaveSlot;
}

typedef LoadSlotsResult = ResultExternalApp & ResultBase & {
	
	/** An array of SaveSlot objects. */
	var slots(default, null):Array<RawSaveSlot>;
}
