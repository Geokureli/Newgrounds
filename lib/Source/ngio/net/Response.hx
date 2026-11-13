package ngio.net;

import haxe.Json;
import ngio.debug.Logger;
import ngio.net.Error;
import ngio.net.results.BaseResultData;
import ngio.net.results.Result;

typedef DebugResponse =
{
	final exec_time:Int;
	final input:Dynamic;
}

@:noCompletion
typedef RawResponse<T:BaseResultData> =
{
	final app_id :String;
	final success:Bool;
	final error  :Null<Error>;
	final debug  :Null<DebugResponse>;
	final result :Null<Result<T>>;
}

abstract Response<T:BaseResultData>(RawResponse<T>)
{
	public var success(get, never):Bool               ; inline function get_success () return this.success;
	public var error  (get, never):Null<Error>        ; inline function get_error   () return this.error;
	public var debug  (get, never):Null<DebugResponse>; inline function get_debug   () return this.debug;
	public var result (get, never):Null<Result<T>>    ; inline function get_result  () return this.result;
	public var appId  (get, never):String             ; inline function get_appId   () return this.app_id;
	
	public function new (logger:Logger, reply:String)
	{
		try
		{
			this = Json.parse(reply);
		}
		catch (e)
		{
			this = Json.parse('{"success":false,"error":{"message":"Error parsing reply:\'$reply\' error:\'$e\'","code":0}}');
		}
		
		if (!success)
			logger.logError('Call unseccessful: $error');
		else if(!result.success)
			logger.logError('${result.component} fail: ${result.error}');
	}
	
	inline public function hasError()
	{
		return success == false || result.success == false;
	}
	
	public function getError()
	{
		if (success == false)
			return error;
		
		if (result.success == false)
			return result.error;
		
		return null;
	}
}
