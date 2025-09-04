package io.newgrounds.net.results.medal;

import io.newgrounds.net.data.MedalData;
import io.newgrounds.net.results.BaseResultData;

typedef RawMedalListData = ExternalAppResultData & BaseResultData & {
	
	final medals:Array<MedalData>;
}

@:forward
abstract MedalListResultData(RawMedalListData) from RawMedalListData to BaseResultData {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}
