package io.newgrounds.objects.events;

import io.newgrounds.objects.Medal.RawMedalData;
import io.newgrounds.objects.ScoreBoard.RawScoreBoardData;
import io.newgrounds.objects.SaveSlot.RawSaveSlot;

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

@:noCompletion
typedef RawGetHostResult = ResultBase
	& { host_approved:Bool }
@:forward
abstract GetHostResult(RawGetHostResult) from RawGetHostResult to ResultBase {
	
	public var host_approved(get, never):Bool;
	@:deprecated("Use hostApproved")
	inline function get_host_approved() return this.host_approved;
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
}

@:noCompletion
typedef RawGetCurrentVersionResult = ResultBase
	& { current_version:String, client_deprecated:Bool }
@:forward
abstract GetCurrentVersionResult(RawGetCurrentVersionResult) from RawGetCurrentVersionResult to ResultBase {
	
	public var current_version(get, never):String;
	@:deprecated("Use currentVersion")
	inline function get_current_version() return this.current_version;
	public var currentVersion(get, never):String;
	inline function get_currentVersion() return this.current_version;
	
	public var client_deprecated(get, never):Bool;
	@:deprecated("Use clientDeprecated")//depreception!
	inline function get_client_deprecated() return this.client_deprecated;
	public var clientDeprecated(get, never):Bool;
	inline function get_clientDeprecated() return this.client_deprecated;
	
}

@:noCompletion
typedef RawLogEventResult = ResultBase
	& { event_name:String }
@:forward
abstract LogEventResult(RawLogEventResult) from RawLogEventResult to ResultBase {
	
	public var event_name(get, never):String;
	@:deprecated("Use eventName")
	inline function get_event_name() return this.event_name;
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}

@:noCompletion
typedef RawGetDateTimeResult = ResultBase
	& { datetime:String }
@:forward
abstract GetDateTimeResult(RawGetDateTimeResult) from RawGetDateTimeResult to ResultBase {
	
	public var datetime(get, never):String;
	@:deprecated("datetime is deprecated, use dateTime (captial T)")
	inline function get_datetime() return this.datetime;
	public var dateTime(get, never):String;
	inline function get_dateTime() return this.datetime;
}

typedef GetVersionResult = ResultBase & {
	
	var version(default, null):String;
}

typedef PingResult = ResultBase & {
	
	var pong(default, null):String;
}

typedef MedalListResult = ResultBase & {
	
	var medals(default, null):Array<RawMedalData>;
}

@:noCompletion
typedef RawMedalUnlockResult = ResultBase
	& { medal_score:String, medal:RawMedalData }
@:forward
abstract MedalUnlockResult(RawMedalUnlockResult) from RawMedalUnlockResult to ResultBase {
	
	public var medal_score(get, never):String;
	@:deprecated("Use medalScore")
	inline function get_medal_score() return this.medal_score;
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
}

typedef ScoreBoardResult = ResultBase & {
	
	var scoreboards(default, null):Array<RawScoreBoardData>;
}

typedef ScoreResult = ResultBase & {
	
	var scores    (default, null):Array<Score>;
	var scoreboard(default, null):RawScoreBoardData;
}

typedef PostScoreResult = ResultBase & {
	
	var tag       (default, null):String;
	var scoreboard(default, null):RawScoreBoardData;
	var score     (default, null):Score;
}

typedef SaveSlotResult = ResultBase & {
	
	var slot(default, null):RawSaveSlot;
}

typedef LoadSlotsResult = ResultBase & {
	
	var slots(default, null):Array<RawSaveSlot>;
}
