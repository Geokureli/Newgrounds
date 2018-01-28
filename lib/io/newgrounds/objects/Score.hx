package io.newgrounds.objects;

class Score extends Object {
	
	/** The value value in the format selected in your scoreboard settings. */
	public var formattedValue(default, null):String;
	
	/** The tag attached to this value (if any). */
	public var tag(default, null):String;
	
	/** The user who earned value. If this property is absent, the value belongs to the active user. */
	public var user(default, null):Dynamic;
	
	/** The integer value of the value. */
	public var value(default, null):Int;
	
	public function new(core:NG, data:Dynamic) { super(core, data); }

	override function parse(data:Dynamic):Void {
		
		//TODO
	}
}