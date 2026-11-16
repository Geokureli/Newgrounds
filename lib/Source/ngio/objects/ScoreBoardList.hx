package ngio.objects;

import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Error;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.Result;
import ngio.net.results.score.GetBoardsResultData;
import ngio.objects.ScoreBoard;

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see ngio.objects.SaveSlot
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract ScoreBoardList (RawScoreBoardList)
{
	inline public function new (core)
	{
		this = new RawScoreBoardList(core);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int) return this._map.get(id);
}

/**
 * Note: `SaveSlotList` is just an abstract wrapper of `RawScoreBoardList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:access(ngio.objects.ScoreBoard)
private class RawScoreBoardList extends ObjectList<Int, ScoreBoard>
{
	public function loadList(?callback:(Outcome<CallError>)->Void)
	{
		if (checkState(callback, false) == false)
			return;
		
		_core.calls.scoreBoard.getBoards()
			.addOutcomeHandler((outcome)->onScoreBoardsReceived(outcome))
			.send();
	}
	
	
	function onScoreBoardsReceived(outcome:CallOutcome<GetBoardsResultData>)
	{
		switch (outcome)
		{
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
				for (boardData in data.scoreboards)
				{
					if (_map.exists(boardData.id))
						_map[boardData.id].parse(boardData);
					else
						_map[boardData.id] = new ScoreBoard(_core, boardData);
				}
				
				_core.logger.logVerbose('${data.scoreboards.length} ScoreBoards received ${data.scoreboards.map(b->b.id)}');
				
				fireCallbacks(SUCCESS);
		}
	}
}

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see ngio.objects.SaveSlot
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract ExternalScoreBoardList (RawScoreBoardList)
{
	inline public function new (core)
	{
		this = new RawScoreBoardList(core);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int):ExternalScoreBoard return this._map.get(id);
}

@:forward
abstract ExternalScoreBoard(ScoreBoard) from ScoreBoard
{
	/** Hides the underlying function. */
	function postScore() {}
}