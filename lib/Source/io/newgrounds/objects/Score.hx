package io.newgrounds.objects;

@:noCompletion
typedef RawScoreData = {
	
	var formatted_value:String;
	var tag:String;
	var user:User;
	var value:Int;
}

/** We don't want to serialize scores since there's a bajillion of them. */
abstract Score(RawScoreData) from RawScoreData {
	
	/** The value value in the format selected in your scoreboard settings. */
	public var formattedValue(get, never):String;
	inline function get_formattedValue() return this.formatted_value;
	
	/** The tag attached to this value (if any). */
	public var tag(get, never):String;
	inline function get_tag() return this.tag;
	
	/** The user who earned value. If this property is absent, the value belongs to the active user. */
	public var user(get, never):User;
	inline function get_user() return this.user;
	
	/** The integer value of the value. */
	public var value(get, never):Int;
	inline function get_value() return this.value;
}