package io.newgrounds.components;

import haxe.Json;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import io.newgrounds.NG;
import io.newgrounds.objects.ScoreBoard;

class ScoreBoardComponent extends Component {
	
	public var all:Array<ScoreBoard>;
	public var allById:IntMap<ScoreBoard>;
	public var allByName:StringMap<ScoreBoard>;
	
	public function new (core:NG){ super(core); }
	
	public function getScores
	( id    :Int
	, limit :Int     = 10
	, skip  :Int     = 0
	, period:String  = null
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call {
		
		if (all == null || !allById.exists(id))
			return ScoreBoard.getScoresHelper(_core, id, limit, skip, period, social, tag, user)
				.addDataHandler(onScoresReceived);
		
		return allById.get(id).getScores(limit, skip, period, social, tag, user);
	}
	
	function onScoresReceived(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		all = new Array<ScoreBoard>();
		allById = new IntMap<ScoreBoard>();
		allByName = new StringMap<ScoreBoard>();
		
		createBoard(data.data.scoreboard).parseScores(data.data.scores);
	}
	
	public function getScoresByName
	( name  :String
	, limit :Int     = 10
	, period:String  = null
	, skip  :Int     = 0
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call {
		
		if (_core.assert(all != null, "Cannot get scores until ScoreBoard.getBoards is called")
		&&  _core.assert(allByName.exists(name), 'Cannot unlock medal, no name matches "$name"'))
			return allByName.get(name).getScores(limit, skip, period, social, tag, user);
		
		return null;
	}
	
	public function postScore(id:Int, value:Int, tag:String = null):Call {
		
		if (all == null)
			return ScoreBoard.postScoreHelper(_core, id, value, tag)
				.addDataHandler(onScorePosted);
		
		if (_core.assert(allById.exists(id), 'no id matches "$id"'))
			return allById.get(id).postScore(value, tag);
		
		return null;
	}
	
	function onScorePosted(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		all = new Array<ScoreBoard>();
		allById = new IntMap<ScoreBoard>();
		allByName = new StringMap<ScoreBoard>();
		
		createBoard(data.data.scoreBoard).parseScores(data.data.scores);
	}
	
	public function postScoreByName(name:String, value:Int):Call {
		
		if (_core.assert(all != null && allByName.exists(name), 'no name matches "$name"'))
			return allByName.get(name).postScore(value);
		
		return null;
	}
	
	public function getBoards():Call {
		
		return new Call(_core, "ScoreBoard.getBoards")
			.addDataHandler(onBoardsReceive);
	}
	
	function onBoardsReceive(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		all = new Array<ScoreBoard>();
		allById = new IntMap<ScoreBoard>();
		allByName = new StringMap<ScoreBoard>();
		
		for (boardData in cast(data.data.scoreboards, Array<Dynamic>))
			createBoard(boardData);
		
		_core.log('${all.length} ScoreBoards loaded');
	}
	
	inline function createBoard(data:Dynamic):ScoreBoard {
		
		var board = new ScoreBoard(_core, data);
		_core.logVerbose('created $board');
		
		all.push(board);
		allById.set(board.id, board);
		allByName.set(board.name, board);
		
		return board;
	}
}