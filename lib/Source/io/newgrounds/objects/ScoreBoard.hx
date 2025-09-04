package io.newgrounds.objects;

import io.newgrounds.net.Call;
import io.newgrounds.net.data.Period;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.data.Score;
import io.newgrounds.net.data.ScoreBoardData;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.Result;
import io.newgrounds.net.results.score.GetScoresResultData;
import io.newgrounds.objects.Object;

using io.newgrounds.net.outcomes.Outcome.OutcomeTools;
using io.newgrounds.net.outcomes.Outcome.TypedOutcomeTools;

class ScoreBoard extends CoreObject<ScoreBoardData> {
	
	public var scores(default, null):Array<Score>;
	
	/** The numeric ID of the scoreboard.*/
	public var id(get, never):Int;
	inline function get_id() return _data.id;
	
	/** The name of the scoreboard. */
	public var name(get, never):String;
	inline function get_name() return _data.name;
	
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
	, ?callback:(Outcome<CallError>)->Void
	) {
		
		_core.calls.scoreBoard.getScores(id, limit, skip, period, social, tag, user)
			.addOutcomeHandler(onScoresReceived.bind(_, callback))
			.send();
	}
	
	function onScoresReceived(outcome:CallOutcome<GetScoresResultData>, callback:Null<(Outcome<CallError>)->Void>):Void {
		
		switch(outcome) { 
			
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
				
				scores = data.scores;
				_core.logger.logVerbose('received ${scores.length} scores');
				
				
				callback.safe(SUCCESS);
				
				onUpdate.dispatch();
		}
	}
	
	public function postScore(value:Int, ?tag:String, ?callback:(Outcome<CallError>)->Void):Void {
		
		final call = _core.calls.scoreBoard.postScore(id, value, tag);
		
		if (callback != null) {
			
			call.addOutcomeHandler(
				(o)->switch (o) {
					
					case FAIL(error): callback(FAIL(error));
					case SUCCESS(data): callback(SUCCESS);
				}
			);
		}
		
		call.send();
	}
	
	public function toString():String {
		
		return 'ScoreBoard: $id@$name';
	}
}
