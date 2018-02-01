package io.newgrounds.objects.events;

import io.newgrounds.objects.events.Result.ResultBase;
import haxe.Json;
import io.newgrounds.objects.Error;

class Response<T:ResultBase> {
	
	public var success(default, null):Bool;
	public var error(default, null):Error;
	public var debug(default, null):Dynamic;//TODO:type
	public var result(default, null):Result<T>;
	
	public function new (core:NGLite, reply:String) {
		
		var data = Json.parse(reply);
		
		success = data.success;
		debug = data.debug;
		
		if (!success) {
			error = new Error(data.error.message, data.error.code);
			core.logError('Call unseccessful: $error');
			return;
		}
		
		result = new Result<T>(core, data.result);
	}
}
