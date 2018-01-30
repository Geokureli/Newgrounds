package io.newgrounds.components;

import haxe.ds.IntMap;
import io.newgrounds.NGLite;
import io.newgrounds.objects.ScoreBoard;

class ScoreBoardComponent extends Component {
	
	public var allById:IntMap<ScoreBoard>;
	
	public function new (core:NGLite){ super(core); }
	
	// -------------------------------------------------------------------------------------------
	//                                       GET SCORES
	// -------------------------------------------------------------------------------------------
	
	public function getBoards():Call {
		
		return new Call(_core, "ScoreBoard.getBoards");
	}
	
	function onBoardsReceive(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		allById = new IntMap<ScoreBoard>();
		
		for (boardData in cast(data.data.scoreboards, Array<Dynamic>))
			createBoard(boardData);
		
		//_core.log('${allById} ScoreBoards loaded');
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       GET SCORES
	// -------------------------------------------------------------------------------------------
	
	public function getScores
	( id    :Int
	, limit :Int     = 10
	, skip  :Int     = 0
	, period:String  = null
	, social:Bool    = false
	, tag   :String  = null
	, user  :Dynamic = null
	):Call {
		
		return new Call(_core, "ScoreBoard.getScores")
			.addComponentParameter("id"    , id    )
			.addComponentParameter("limit" , limit , 10   )
			.addComponentParameter("skip"  , skip  , 0    )
			.addComponentParameter("period", period, null )
			.addComponentParameter("social", social, false)
			.addComponentParameter("tag"   , tag   , null )
			.addComponentParameter("user"  , user  , null );
	}
	
	function onScoresReceived(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		allById = new IntMap<ScoreBoard>();
		
		//createBoard(data.data.scoreboard).parseScores(data.data.scores);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       POST SCORE
	// -------------------------------------------------------------------------------------------
	
	public function postScore(id:Int, value:Int, tag:String = null):Call {
		
		return new Call(_core, "ScoreBoard.postScore", true, true)
			.addComponentParameter("id"   , id)
			.addComponentParameter("value", value)
			.addComponentParameter("tag"  , tag);
	}
	
	function onScorePosted(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		allById = new IntMap<ScoreBoard>();
		
		//createBoard(data.data.scoreBoard).parseScores(data.data.scores);
	}
	
	inline function createBoard(data:Dynamic):ScoreBoard {
		
		var board = new ScoreBoard(_core, data);
		_core.logVerbose('created $board');
		
		allById.set(board.id, board);
		
		return board;
	}
}