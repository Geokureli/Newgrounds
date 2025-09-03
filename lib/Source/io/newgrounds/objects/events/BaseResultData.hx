package io.newgrounds.objects.events;

typedef BaseResultData = {
	
	var success(default, null):Bool;
	var debug  (default, null):Bool;
	var error  (default, null):Error;
}

typedef SessionResultData = BaseResultData & {
	
	var session(default, null):Session;
}


typedef ExternalAppData = {
	
	/** The App ID of another, approved app to load medals from. */
	var app_id(default, null):String;
}
