package ngio.net.results.app;

import ngio.net.results.BaseResultData;

@:noCompletion
typedef RawGetHostData = BaseResultData &
{
	final host_approved:Bool;
}

@:forward
abstract GetHostResultData(RawGetHostData) from RawGetHostData to BaseResultData
{
	/** Wether the host is in the approved list. */
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
	
	var host_approved(get, never):Bool;
	inline function get_host_approved() return this.host_approved;
}
