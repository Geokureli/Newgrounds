package ngio.net.results.app;

import ngio.net.results.BaseResultData;

@:noCompletion
typedef RawGetCurrentVersionData = BaseResultData &
{
	final current_version:String;
	final client_deprecated:Bool;
}

@:forward
abstract GetCurrentVersionResultData(RawGetCurrentVersionData) from RawGetCurrentVersionData to BaseResultData
{
	/** The version number of the app as defined in your "Version Control" settings. */
	public var currentVersion(get, never):String;
	inline function get_currentVersion() return this.current_version;
	
	/** Hidden, use currentVersion instead. */
	public var current_version(get, never):String;
	@:deprecated("Use currentVersion")
	inline function get_current_version() return this.current_version;
	
	/** Notes whether the client-side app is using a lower version number. */
	public var clientDeprecated(get, never):Bool;
	inline function get_clientDeprecated() return this.client_deprecated;
	
	/** Hidden, use clientDeprecated instead. */
	public var client_deprecated(get, never):Bool;
	@:deprecated("Use clientDeprecated")//depreception!
	inline function get_client_deprecated() return this.client_deprecated;
}
