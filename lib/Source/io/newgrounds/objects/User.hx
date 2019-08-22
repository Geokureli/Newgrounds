package io.newgrounds.objects;

@:noCompletion
typedef RawUserData = {
	
	icons    :UserIcons,
	id       :Int,
	name     :String,
	supporter:Bool,
	url      :String
}

abstract User(RawUserData) from RawUserData {
	
	/** The user's icon images. */
	public var icons(get, never):UserIcons;
	inline function get_icons() return this.icons;
	
	/** The user's numeric ID. */
	public var id(get, never):Int;
	inline function get_id() return this.id;
	
	/** The user's textual name. */ 
	public var name     (get, never):String;
	inline function get_name() return this.name;
	
	/** Returns true if the user has a Newgrounds Supporter upgrade. */ 
	public var supporter(get, never):Bool;
	inline function get_supporter() return this.supporter;
	
	/** The user's NG profile url. */
	public var url(get, never):String;
	inline function get_url() return this.url;
}
