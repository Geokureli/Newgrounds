package io.newgrounds.objects;

import io.newgrounds.components.ScoreBoardComponent.Period;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Result.ScoreResult;
import io.newgrounds.NGLite;

@:noCompletion
typedef RawScoreBoardData = {
	
	id  :Int,
	name:String
}

class ScoreBoard extends Object<RawScoreBoardData> {
	
	public var scores(default, null):Array<Score>;
	
	/** The numeric ID of the scoreboard.*/
	public var id(get, never):Int;
	inline function get_id() return _data.id;
	
	/** The name of the scoreboard. */
	public var name(get, never):String;
	inline function get_name() return _data.name;
	
	public function new(core:NGLite, data:RawScoreBoardData):Void {super(core, data); }

	/**
	 * Fetches score data from the server, this removes all of the existing scores cached
	 * 
	 * We don't unify the old and new scores because a user's rank or score may change between requests
	 */
	public function requestScores
	( limit :Int     = 10
	, skip  :Int     = 0
	, period:Period  = Period.ALL
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Void {
		
		_core.calls.scoreBoard.getScores(id, limit, skip, period, social, tag, user)
			.addDataHandler(onScoresReceived)
			.send();
	}
	
	function onScoresReceived(response:Response<ScoreResult>):Void {
		
		if (!response.success || !response.result.success)
			return;
		
		scores = response.result.data.scores;
		_core.logVerbose('received ${scores.length} scores');
		
		onUpdate.dispatch();
	}
	
	public function postScore(value :Int, tag:String = null):Void {
		
		_core.calls.scoreBoard.postScore(id, value, tag)
			.addDataHandler(onScorePosted)
			.send();
	}
	
	function onScorePosted(response:Response<PostScoreResult>):Void {
		
		
	}
	
	public function toString():String {
		
		return 'ScoreBoard: $id@$name';
	}
	
}