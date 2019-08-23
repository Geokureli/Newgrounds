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

typedef GetHostResult = ResultBase & {
	
	var host_approved(default, null):Bool;
}

typedef GetCurrentVersionResult = ResultBase & {
	
	var current_version  (default, null):String;
	var client_deprecated(default, null):Bool;
}

typedef LogEventResult = ResultBase & {
	
	var event_name(default, null):String;
}

typedef GetDateTimeResult = ResultBase & {
	
	var datetime(default, null):String;
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

typedef MedalUnlockResult = ResultBase & {
	
	var medal_score(default, null):String;
	var medal      (default, null):RawMedalData;
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
