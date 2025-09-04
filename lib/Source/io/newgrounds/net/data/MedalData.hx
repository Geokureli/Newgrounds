package io.newgrounds.net.data;

typedef MedalData =
{
	id         :Int,
	name       :String,
	description:String,
	icon       :String,
	value      :Int,
	difficulty :Difficulty,
	secret     :Int,
	unlocked   :Bool
}

enum abstract Difficulty(Int) from Int to Int {
	
	var EASY        = 1;
	var MODERATE    = 2;
	var CHALLENGING = 3;
	var DIFFICULT   = 4;
	var BRUTAL      = 5;
}