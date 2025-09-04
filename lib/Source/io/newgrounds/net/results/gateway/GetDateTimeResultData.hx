package io.newgrounds.net.results.gateway;

import io.newgrounds.net.results.BaseResultData;

using DateTools;

@:noCompletion
typedef RawGetDateTimeData = BaseResultData
	& { datetime:String, timestamp:Int }

@:forward
abstract GetDateTimeResultData(RawGetDateTimeData) from RawGetDateTimeData to BaseResultData {
	
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
