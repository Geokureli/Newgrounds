package io.newgrounds.net.data;

typedef User = {
	
	/** The user's icon images. */
	final icons    :UserIcons;
	
	/** The user's numeric ID. */
	final id       :Int;
	
	/** The user's textual name. */ 
	final name     :String;
	
	/** Returns true if the user has a Newgrounds Supporter upgrade. */ 
	final supporter:Bool;
	
	/** The user's NG profile url. */
	final url      :String;
}