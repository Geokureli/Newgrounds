package io.newgrounds.utils;

import io.newgrounds.Call;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.SaveSlot
**/
@:forward
@:access(io.newgrounds.utils.ObjectList)
abstract ScoreBoardList (RawScoreBoardList) {
	
	inline public function new (core:NG) {
		
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
@:access(io.newgrounds.objects.ScoreBoard)
private class RawScoreBoardList extends ObjectList<Int, ScoreBoard> {
	
	public function loadList(?callback:(Outcome<CallError>)->Void) {
		
		if (checkState(callback, false) == false)
			return;
		
		_core.calls.scoreBoard.getBoards()
			.addOutcomeHandler((outcome)->onScoreBoardsReceived(outcome))
			.sendExternalAppId(_externalAppId);
	}
	
	
	function onScoreBoardsReceived(outcome:CallOutcome<GetBoardsData>) {
		
		switch (outcome) {
			
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
				
				var idList:Array<Int> = new Array<Int>();
				
				if (_map == null) {
					
					_map = new Map();
					
					for (boardData in data.scoreboards) {
						
						var board = new ScoreBoard(_core, boardData);
						_map.set(board.id, board);
						idList.push(board.id);
					}
				}
				
				_core.logVerbose('${data.scoreboards.length} ScoreBoards received [${idList.join(", ")}]');
				
				fireCallbacks(SUCCESS);
		}
	}
}

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.SaveSlot
**/
@:forward
@:access(io.newgrounds.utils.ObjectList)
abstract ExternalScoreBoardList (RawScoreBoardList) {
	
	inline public function new (core:NG, externalAppId:String) {
		
		this = new RawScoreBoardList(core, externalAppId);
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