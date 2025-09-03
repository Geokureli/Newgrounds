package io.newgrounds.components.event;

import io.newgrounds.objects.events.BaseResultData;

@:noCompletion
typedef RawLogEventData = BaseResultData
	& { event_name:String }

@:forward
abstract LogEventData(RawLogEventData) from RawLogEventData to BaseResultData {
	
	/** Hidden, use eventName instead . */
	public var event_name(get, never):String;
	@:deprecated("Use eventName")
	inline function get_event_name() return this.event_name;
	
	/** The event that was logged. */
	public var eventName(get, never):String;
	inline function get_eventName() return this.event_name;
}
