package ngio.net.results.event;

import ngio.net.results.BaseResultData;

@:noCompletion
typedef RawLogEventData = BaseResultData &
{
	final event_name:String;
}

@:forward
abstract LogEventResultData(RawLogEventData) from RawLogEventData to BaseResultData {
	
	var event_name(get, never):String;
	inline function get_event_name() return this.event_name;
	
	/** The event that was logged. */
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}
