package io.newgrounds.objects;

@:noCompletion
typedef RawUserIconsData = {
	
	large :String,
	medium:String,
	small :String
}

abstract UserIcons(RawUserIconsData) from RawUserIconsData {
	
	/**The URL of the user's large icon. */
	public var large(get, never):String;
	inline function get_large() return this.large;
	
	/** The URL of the user's medium icon. */
	public var medium(get, never):String;
	inline function get_medium() return this.medium;
	
	/** The URL of the user's small icon. */
	public var small(get, never):String;
	inline function get_small() return this.small;
}