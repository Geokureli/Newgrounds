package ngio.net.results;

import ngio.net.Error;

@:noCompletion
typedef RawResult<T:BaseResultData> =
{
	var component(default, null):String;
	var echo     (default, null):String;
	var data     (default, null):T;
}

abstract Result<T:BaseResultData>(RawResult<T>) from RawResult<T>
{
	public var component(get, never):String; inline function get_component() return this.component;
	public var echo     (get, never):String; inline function get_echo     () return this.echo;
	public var data     (get, never):T     ; inline function get_data     () return this.data;
	public var success  (get, never):Bool  ; inline function get_success  () return data.success;
	public var debug    (get, never):Bool  ; inline function get_debug    () return data.debug;
	public var error    (get, never):Error ; inline function get_error    () return data.error;
}