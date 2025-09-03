package io.newgrounds.components.app;

import io.newgrounds.objects.events.BaseResultData;

@:noCompletion
typedef RawGetHostData = BaseResultData
	& { host_approved:Bool }

@:forward
abstract GetHostData(RawGetHostData) from RawGetHostData to BaseResultData {
	
	/** Wether the host is in the approved list. */
	public var hostApproved(get, never):Bool;
	inline function get_hostApproved() return this.host_approved;
	
	/** Hidden, use currentVersion instead. */
	public var host_approved(get, never):Bool;
	@:deprecated("Use hostApproved")
	inline function get_host_approved() return this.host_approved;
}
