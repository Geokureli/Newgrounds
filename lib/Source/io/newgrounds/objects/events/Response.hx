package io.newgrounds.objects.events;

import haxe.Json;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Result;

typedef DebugResponse = {
	
	var exec_time:Int;
	var input:Dynamic;
}

@:noCompletion
typedef RawResponse<T:ResultBase> =
{
	success:Bool,
	?error :Error,
	?debug :DebugResponse,
	?result:Result<T>,
	app_id :String
}

abstract Response<T:ResultBase>(RawResponse<T>) {
	
	public var success(get, never):Bool               ; inline function get_success () return this.success;
	public var error  (get, never):Null<Error>        ; inline function get_error   () return this.error;
	public var debug  (get, never):Null<DebugResponse>; inline function get_debug   () return this.debug;
	public var result (get, never):Null<Result<T>>    ; inline function get_result  () return this.result;
	public var appId  (get, never):String             ; inline function get_appId   () return this.app_id;
	
	public function new (core:NGLite, reply:String) {
		
		try { this = Json.parse(reply); }
		catch (e:Dynamic) {
			
			this = Json.parse('{"success":false,"error":{"message":"Error parsing reply:\'$reply\' error:\'$e\'","code":0}}');
		}
		
		if (!success)
			core.logError('Call unseccessful: $error');
		else if(!result.success)
			core.logError('${result.component} fail: ${result.error}');
	}
}
