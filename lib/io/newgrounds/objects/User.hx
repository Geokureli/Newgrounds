package io.newgrounds.objects;

class User extends Object {
	
	/** The user's icon images. */
	public var icons(default, null):UserIcons;
	
	/** The user's numeric ID. */
	public var id(default, null):Int;
	
	/** The user's textual name. */ 
	public var name(default, null):String;
	
	/**Returns true if the user has a Newgrounds Supporter upgrade. */ 
	public var supporter(default, null):Bool;
	
	public function new(core:NGLite, data:Dynamic) { super(core, data); }

	override function parse(data:Dynamic):Void {
		
		id = data.id;
		name = data.name;
		supporter = data.supporter;
		
		if (data.icons != null) {
			
			if (icons != null)
				icons.parse(data.icons);
			else
				icons = new UserIcons(_core, data.icons);
		}
		
		super.parse(data);
	}
}
