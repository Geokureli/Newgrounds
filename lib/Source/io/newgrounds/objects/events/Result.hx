package io.newgrounds.objects.events;

import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.objects.Medal.RawMedalData;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.objects.SaveSlot.RawSaveSlot;
import io.newgrounds.objects.User;

using DateTools;

@:noCompletion
typedef RawResult<T:BaseData> = {
	
	var component(default, null):String;
	var echo     (default, null):String;
	var data     (default, null):T;
}

abstract Result<T:BaseData>(RawResult<T>) from RawResult<T> {
	
	public var component(get, never):String; inline function get_component() return this.component;
	public var echo     (get, never):String; inline function get_echo     () return this.echo;
	public var data     (get, never):T     ; inline function get_data     () return this.data;
	public var success  (get, never):Bool  ; inline function get_success  () return data.success;
	public var debug    (get, never):Bool  ; inline function get_debug    () return data.debug;
	public var error    (get, never):Error ; inline function get_error    () return data.error;
}

typedef BaseData = {
	
	var success(default, null):Bool;
	var debug  (default, null):Bool;
	var error  (default, null):Error;
}

typedef SessionData = BaseData & {
	
	var session(default, null):Session;
}

typedef ExternalAppData = {
	
	/** The App ID of another, approved app to load medals from. */
	var app_id(default, null):String;
}

@:noCompletion
typedef RawGetHostData = BaseData
	& { host_approved:Bool }
@:forward
abstract GetHostData(RawGetHostData) from RawGetHostData to BaseData {
	
	/** Wether the host is in the approved list. */
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
	
	/** Hidden, use currentVersion instead. */
	public var host_approved(get, never):Bool;
	@:deprecated("Use hostApproved")
	inline function get_host_approved() return this.host_approved;
}

@:noCompletion
typedef RawGetCurrentVersionData = BaseData
	& { current_version:String, client_deprecated:Bool }
@:forward
abstract GetCurrentVersionData(RawGetCurrentVersionData) from RawGetCurrentVersionData to BaseData {
	
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
typedef RawLogEventData = BaseData
	& { event_name:String }
@:forward
abstract LogEventData(RawLogEventData) from RawLogEventData to BaseData {
	
	/** Hidden, use eventName instead . */
	public var event_name(get, never):String;
	@:deprecated("Use eventName")
	inline function get_event_name() return this.event_name;
	
	/** The event that was logged. */
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}

@:noCompletion
typedef RawGetDateTimeData = BaseData
	& { datetime:String, timestamp:Int }
@:forward
abstract GetDateTimeData(RawGetDateTimeData) from RawGetDateTimeData to BaseData {
	
	/** The current UNIX timestamp on the server. */
	public var timestamp(get, never):Int;
	inline function get_timestamp() return this.timestamp;
	
	/** Hidden, use dateTime instead (capital T). */
	var datetime(get, never):String;
	@:deprecated("datetime is deprecated, use dateTime (captial T)")
	inline function get_datetime() return this.datetime;
	
	/** The server's date and time in ISO 8601 format. */
	public var dateTime(get, never):String;
	inline function get_dateTime() return this.datetime;
	
	/** Creates a local Date using the UNIX timestamp. */
	inline public function getDate():Date return Date.fromTime(timestamp * 1000);
	
	/** Creates a local Date using the UNIX timestamp. */
	public function getServerDate() {
		
		var date = Date.fromTime(timestamp * 1000);
		
		final splitIso = dateTime.substr(-6).split(":");
		var serverTimeZone = Std.parseInt(splitIso[0]) * 60;
		serverTimeZone += (serverTimeZone < 0 ? -1 : 1) * Std.parseInt(splitIso[1]);
		final localTimeZone = date.getTimezoneOffset();
		
		return date.delta((localTimeZone + serverTimeZone) * 60 * 1000);
	}
}

typedef GetVersionData = BaseData & {
	
	/** The version number (in X.Y.Z format). */
	var version(default, null):String;
}

typedef PingData = BaseData & {
	
	/** Will always have a value of 'pong'. */
	var pong(default, null):String;
}

typedef RawMedalListData = ExternalAppData & BaseData
	& { medals:Array<RawMedalData> }
@:forward
abstract MedalListData(RawMedalListData) from RawMedalListData to BaseData {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}

typedef RawMedalScoreData = BaseData
	& { medal_score:Int }
@:forward
abstract MedalScoreData(RawMedalScoreData) from RawMedalScoreData to BaseData {
	
	/** The user's medal score. */
	public var medalScore(get, never):Int;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	var medal_score(get, never):Int;
	inline function get_medal_score() return this.medal_score;
}

@:noCompletion
typedef RawMedalUnlockData = BaseData
	& { medal_score:String, medal:RawMedalData }
@:forward
abstract MedalUnlockData(RawMedalUnlockData) from RawMedalUnlockData to BaseData {
	
	/** The user's new medal score. */
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
	/* Hidden, use medalScore instead. */
	public var medal_score(get, never):String;
	@:deprecated("Use medalScore")
	inline function get_medal_score() return this.medal_score;
}

typedef GetBoardsData = BaseData & {
	
	/** An array of ScoreBoard objects. */
	var scoreboards(default, null):Array<RawScoreBoardData>;
}

typedef RawGetScoresData = ExternalAppData & BaseData & {
	
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
abstract GetScoresData(RawGetScoresData) from RawGetScoresData to BaseData {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}

typedef PostScoreData = BaseData & {
	
	/** The ScoreBoard that was posted to. */
	var scoreboard(default, null):RawScoreBoardData;
	/* The Score that was posted to the board. */
	var score     (default, null):Score;
}

typedef SaveSlotData = BaseData & {
	
	/** The save slot that was changed. */
	var slot(default, null):RawSaveSlot;
}

typedef LoadSlotsData = ExternalAppData & BaseData & {
	
	/** An array of SaveSlot objects. */
	var slots(default, null):Array<RawSaveSlot>;
}
