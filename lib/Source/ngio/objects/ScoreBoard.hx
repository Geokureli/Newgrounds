package ngio.objects;

import ngio.data.PeriodData;
import ngio.data.ScoreBoardData;
import ngio.data.ScoreData;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.Result;
import ngio.net.results.score.GetScoresResultData;
import ngio.objects.Object;

using ngio.net.Outcome.OutcomeTools;
using ngio.net.Outcome.TypedOutcomeTools;

class ScoreBoard extends CoreObject<ScoreBoardData>
{
	public var scores(default, null):Array<ScoreData>;
	
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
		( limit    :Int        = 10
		, skip     :Int        = 0
		, period   :PeriodData = ALL
		, social   :Bool       = false
		, tag      :String     = null
		, user     :Dynamic    = null
		, ?callback:(Outcome<CallError>)->Void
		)
	{
		_core.calls.scoreBoard.getScores(id, limit, skip, period, social, tag, user)
			.addOutcomeHandler(onScoresReceived.bind(_, callback))
			.send();
	}
	
	function onScoresReceived(outcome:CallOutcome<GetScoresResultData>, callback:Null<(Outcome<CallError>)->Void>)
	{
		switch(outcome)
		{
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
				
				scores = data.scores;
				_core.logger.logVerbose('received ${scores.length} scores');
				
				
				callback.safe(SUCCESS);
				
				onUpdate.dispatch();
		}
	}
	
	public function postScore(value:Int, ?tag:String, ?callback:(Outcome<CallError>)->Void)
	{
		final call = _core.calls.scoreBoard.postScore(id, value, tag);
		
		if (callback != null)
		{
			call.addOutcomeHandler
			(
				(o)->switch (o)
				{
					case FAIL(error): callback(FAIL(error));
					case SUCCESS(data): callback(SUCCESS);
				}
			);
		}
		
		call.send();
	}
	
	public function toString() return 'ScoreBoard: $id@$name';
}
