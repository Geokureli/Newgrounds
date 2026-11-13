package ngio.data;

@:noCompletion
typedef RawScoreData =
{
	/** The value value in the format selected in your scoreboard settings. */
	final formatted_value:String;
	/** The tag attached to this value (if any). */
	final tag            :String;
	/** The user who earned value. If this property is absent, the value belongs to the active user. */
	final user           :UserData;
	/** The integer value of the value. */
	final value          :Int;
}

/** We don't want to serialize scores since there's a bajillion of them. */
@:forward
abstract ScoreData(RawScoreData) from RawScoreData
{
	/** The value value in the format selected in your scoreboard settings. */
	public var formatted_value(get, never):String;
	@:deprecated("Use formattedValue")
	inline function get_formatted_value() return this.formatted_value;
	
	/** The value value in the format selected in your scoreboard settings. */
	public var formattedValue(get, never):String;
	inline function get_formattedValue() return this.formatted_value;
	
}