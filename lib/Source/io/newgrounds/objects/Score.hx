package io.newgrounds.objects;

@:noCompletion
typedef RawScoreData = {
	
	/** The value value in the format selected in your scoreboard settings. */
	var formatted_value(default, null):String;
	/** The tag attached to this value (if any). */
	var tag            (default, null):String;
	/** The user who earned value. If this property is absent, the value belongs to the active user. */
	var user           (default, null):User;
	/** The integer value of the value. */
	var value          (default, null):Int;
}

/** We don't want to serialize scores since there's a bajillion of them. */
@:forward
abstract Score(RawScoreData) from RawScoreData {
	
	/** The value value in the format selected in your scoreboard settings. */
	public var formatted_value(get, never):String;
	@:deprecated("Use formattedValue")
	inline function get_formatted_value() return this.formatted_value;
	/** The value value in the format selected in your scoreboard settings. */
	public var formattedValue(get, never):String;
	inline function get_formattedValue() return this.formatted_value;
	
}