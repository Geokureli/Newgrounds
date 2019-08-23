package io.newgrounds.objects;

typedef User = {
	
	var icons    (default, null):UserIcons;
	var id       (default, null):Int;
	var name     (default, null):String;
	var supporter(default, null):Bool;
	var url      (default, null):String;
}