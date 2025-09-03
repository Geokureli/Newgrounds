package io.newgrounds.components.medal;

import io.newgrounds.objects.Medal;
import io.newgrounds.objects.events.BaseResultData;

typedef RawMedalListData = ExternalAppData & BaseResultData
	& { medals:Array<RawMedalData> }

@:forward
abstract MedalListData(RawMedalListData) from RawMedalListData to BaseResultData {
	
	/** The App ID of another, approved app to load medals from. */
	public var externalAppId(get, never):String;
	inline function get_externalAppId():String return this.app_id;
	
	/* Hidden, use externalAppId instead. */
	var app_id(get, never):String;
	inline function get_app_id():String return this.app_id;
}
