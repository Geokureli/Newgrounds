package io.newgrounds.objects;

class UserIcons extends Object{

	/**The URL of the user's large icon. */
	public var large(default, null):String;
	
	/** The URL of the user's medium icon. */
	public var medium(default, null):String;
	
	/** The URL of the user's small icon. */
	public var small(default, null):String;
	
	public function new(core:NG, data:Dynamic) { super(core, data); }
	
	override function parse(data:Dynamic):Void {
		
		//TODO
	}
}

