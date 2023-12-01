package io.newgrounds.objects;

import io.newgrounds.Call;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result;
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
	, ?callback:(Outcome<CallError>)->Void
	) {
		
		_core.calls.scoreBoard.getScores(id, limit, skip, period, social, tag, user)
			.addOutcomeHandler(onScoresReceived.bind(_, callback))
			.send();
	}
	
	function onScoresReceived(outcome:CallOutcome<GetScoresData>, callback:Null<(Outcome<CallError>)->Void>):Void {
		
		switch(outcome) { 
			
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
				
				scores = data.scores;
				_core.logVerbose('received ${scores.length} scores');
				
				
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
