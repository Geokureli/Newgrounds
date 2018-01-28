package io.newgrounds.objects;

import io.newgrounds.NG;
class ScoreBoard extends Object {
	
	public var scores(default, null):Array<Dynamic>;
	
	/** The numeric ID of the scoreboard.*/
	public var id(default, null):Int;
	
	/** The name of the scoreboard. */
	public var name(default, null):String;
	
	public function new(core:NG, data:Dynamic):Void {super(core, data); }
	
	override function parse(data:Dynamic):Void {
		
		id   = data.id;
		name = data.name;
	}
	
	public function getScores
	( limit :Int     = 10
	, skip  :Int     = 0
	, period:String  = null
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call {
		
		return getScoresHelper(_core, id, limit, skip, period, social, tag, user)
			.addDataHandler(onScoresReceived);
	}
	
	function onScoresReceived(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		parseScores(cast data.data.scores);
	}
	
	public function parseScores(scores:Array<Dynamic>):Void {
		
		//TODO: keep old scores and unify new + old?
		scores = new Array<Score>();
		
		for (boardData in scores)
			scores.push(new ScoreBoard(_core, boardData));
		
		_core.log('created ${scores.length} scores');
	}
	
	public function postScore(value :Int, tag:String = null):Call {
		
		return postScoreHelper(_core, id, value, tag);
	}
	
	public function toString():String {
		
		return 'ScoreBoard: $id@$name';
	}
	
	inline static public function getScoresHelper
	( core  :NG
	, id    :Int
	, limit :Int     = 10
	, skip  :Int     = 0
	, period:String  = null
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call {
		
		return new Call(core, "ScoreBoard.getScores")
			.addComponentParameter("id"    , id    )
			.addComponentParameter("limit" , limit , 10   )
			.addComponentParameter("skip"  , skip  , 0    )
			.addComponentParameter("period", period, null )
			.addComponentParameter("social", social, false)
			.addComponentParameter("tag"   , tag   , null )
			.addComponentParameter("user"  , user  , null );
	}
	
	inline static public function postScoreHelper(core:NG, id:Int, value :Int, tag:String = null):Call {
		
		return new Call(core, "ScoreBoard.postScore", true, true)
			.addComponentParameter("id", id)
			.addComponentParameter("tag", tag)
			.addComponentParameter("value", value);
	}
}