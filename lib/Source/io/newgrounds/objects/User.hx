package io.newgrounds.objects;

typedef User = {
	
	/** The user's icon images. */
	var icons    (default, null):UserIcons;
	/** The user's numeric ID. */
	var id       (default, null):Int;
	/** The user's textual name. */ 
	var name     (default, null):String;
	/** Returns true if the user has a Newgrounds Supporter upgrade. */ 
	var supporter(default, null):Bool;
	/** The user's NG profile url. */
	var url      (default, null):String;
}