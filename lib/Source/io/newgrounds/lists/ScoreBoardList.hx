package io.newgrounds.lists;

import io.newgrounds.net.Call;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.Result;
import io.newgrounds.net.results.score.GetBoardsResultData;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.utils.Dispatcher;

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @seeio.newgrounds.objects.SaveSlot
**/
@:forward
@:access(io.newgrounds.lists.ObjectList)
abstract ScoreBoardList (RawScoreBoardList) {
	
	inline public function new (core) {
		
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
@:access(io.newgrounds.lists.ScoreBoard)
private class RawScoreBoardList extends ObjectList<Int, ScoreBoard> {
	
	public function loadList(?callback:(Outcome<CallError>)->Void) {
		
		if (checkState(callback, false) == false)
			return;
		
		_core.calls.scoreBoard.getBoards()
			.addOutcomeHandler((outcome)->onScoreBoardsReceived(outcome))
			.send();
	}
	
	
	function onScoreBoardsReceived(outcome:CallOutcome<GetBoardsResultData>) {
		
		switch (outcome) {
			
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
				
				for (boardData in data.scoreboards) {
					
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
 * @seeio.newgrounds.objects.SaveSlot
**/
@:forward
@:access(io.newgrounds.lists.ObjectList)
abstract ExternalScoreBoardList (RawScoreBoardList) {
	
	inline public function new (core) {
		
		this = new RawScoreBoardList(core);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int):ExternalScoreBoard return this._map.get(id);
}

@:forward
abstract ExternalScoreBoard(ScoreBoard) from ScoreBoard {
	
	/** Hides the underlying function. */
	function postScore() {}
}