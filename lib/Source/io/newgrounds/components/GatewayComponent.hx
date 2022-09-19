package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class GatewayComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function getDatetime():Call<GetDateTimeResult> {
		
		return new Call<GetDateTimeResult>(_core, "Gateway.getDatetime");
	}
	
	public function getVersion():Call<GetVersionResult> {
		
		return new Call<GetVersionResult>(_core, "Gateway.getVersion");
	}
	
	public function ping():Call<PingResult> {
		
		return new Call<PingResult>(_core, "Gateway.ping");
	}
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