package ngio.data;

typedef MedalData =
{
	id         :Int,
	name       :String,
	description:String,
	icon       :String,
	value      :Int,
	difficulty :Difficulty,
	secret     :IntBool,
	unlocked   :Bool
}

enum abstract Difficulty(Int) from Int to Int {
	
	var EASY        = 1;
	var MODERATE    = 2;
	var CHALLENGING = 3;
	var DIFFICULT   = 4;
	var BRUTAL      = 5;
	
	public function toString()
	{
		return switch(abstract)
		{
			case EASY       : "Easy";
			case MODERATE   : "Moderate";
			case CHALLENGING: "Challenging";
			case DIFFICULT  : "Difficult";
			case BRUTAL     : "Brutal";
			case wtf:
				throw 'invalid difficulty: $wtf';
		}
	}
}