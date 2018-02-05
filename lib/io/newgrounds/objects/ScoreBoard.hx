package io.newgrounds.objects;

import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Result.ScoreResult;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.NGLite;

class ScoreBoard extends Object {
	
	public var scores(default, null):Array<Dynamic>;
	
	/** The numeric ID of the scoreboard.*/
	public var id(default, null):Int;
	
	/** The name of the scoreboard. */
	public var name(default, null):String;
	
	public function new(core:NGLite, data:Dynamic):Void {super(core, data); }
	
	override function parse(data:Dynamic):Void {
		
		id   = data.id;
		name = data.name;
		
		super.parse(data);
	}
	
	public function getScores
	( limit :Int     = 10
	, skip  :Int     = 0
	, period:String  = null
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call<ScoreResult> {
		
		return _core.calls.scoreBoard.getScores(id, limit, skip, period, social, tag, user);
	}
	
	@:allow(ScoreBoardComponent)
	function parseScores(scores:Array<Dynamic>):Void {
		
		scores = new Array<Score>();
		
		for (boardData in scores)
			scores.push(new ScoreBoard(_core, boardData));
		
		_core.log('created ${scores.length} scores');
	}
	
	public function postScore(value :Int, tag:String = null):Call<ResultBase> {
		
		return _core.calls.scoreBoard.postScore(id, value, tag);
	}
	
	public function toString():String {
		
		return 'ScoreBoard: $id@$name';
	}
	
}