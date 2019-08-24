package io.newgrounds.objects;

@:noCompletion
typedef RawErrorData = {
	
	message:String,
	?code  :Int
}


abstract Error(RawErrorData) from RawErrorData {
	
	public var code   (get, never):Null<Int>; inline function get_code   () return this.code;
	public var message(get, never):String   ; inline function get_message() return this.message;
	
	inline public function new(message:String, ?code:Int)
	{
		this = { message:message, code:code };
	}
	
	inline public function toString():String {
		
		return (code != null ? '#$code - ' : "") + message;
	}
}
