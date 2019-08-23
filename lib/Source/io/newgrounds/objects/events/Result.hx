package io.newgrounds.objects.events;

import io.newgrounds.objects.Medal.RawMedalData;
import io.newgrounds.objects.ScoreBoard.RawScoreBoardData;

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
abstract GetHostResult(RawGetHostResult) from RawGetHostResult to ResultBase {
	
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
}

@:noCompletion
typedef RawGetCurrentVersionResult = ResultBase
	& { current_version:String, client_deprecated:Bool }
abstract GetCurrentVersionResult(RawGetCurrentVersionResult) from RawGetCurrentVersionResult to ResultBase {
	
	public var currentVersion(get, never):String;
	inline function get_currentVersion() return this.current_version;
	
	public var clientDeprecated(get, never):Bool;
	inline function get_clientDeprecated() return this.client_deprecated;
	
}

@:noCompletion
typedef RawLogEventResult = ResultBase
	& { event_name:String }
abstract LogEventResult(RawLogEventResult) from RawLogEventResult to ResultBase {
	
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}

@:noCompletion
typedef RawGetDateTimeResult = ResultBase
	& { datetime:String }
abstract GetDateTimeResult(RawGetDateTimeResult) from RawGetDateTimeResult to ResultBase {
	
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

abstract MedalUnlockResult(RawMedalUnlockResult) from RawMedalUnlockResult to ResultBase {
	
	public var medalScore(get, never):String;
	inline function get_medalScore() return this.medal_score;
	
	public var medal(get, never):RawMedalData;
	inline function get_medal() return this.medal;
	
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
