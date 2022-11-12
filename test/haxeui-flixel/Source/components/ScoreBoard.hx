package components;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.ScoreBoard;

import haxe.ui.events.MouseEvent;

typedef ScoreItem = {rank:String, user:String, score:String};

@:build(haxe.ui.ComponentBuilder.build("Assets/data/components/scoreboard.xml"))
class ScoreBoard extends haxe.ui.containers.VBox
{
	static final periodValues:Array<Period> = [ALL, DAY, WEEK, MONTH, YEAR];
	
	public var page(default, null) = 1;
	
	public var size(get, never):Int;
	inline function get_size() return scoreList.dataSource.size;
	
	public var period(get, set):Period;
	function get_period()
	{
		return periodValues[periodDropDown.selectedIndex];
	}
	function set_period(value:Period)
	{
		periodDropDown.selectedIndex = periodValues.indexOf(value);
		return value;
	}
	
	public function new () { super(); }
	
	override function onReady()
	{
		super.onReady();
		
		clearScores();
	}
	
	@:bind(prev, MouseEvent.CLICK)
	function clickprev(_)
	{
		page--;
		prev.disabled = (page == 1);
		loadScores();
	}
	
	@:bind(next, MouseEvent.CLICK)
	function clickNext(_)
	{
		page++;
		prev.disabled = false;
		loadScores();
	}
	
	public function loadBoards()
	{
		NG.core.scoreBoards.loadList(onBoardsReceive);
	}
	
	function onBoardsReceive(outcome:Outcome<CallError>)
	{
		switch outcome
		{
			case FAIL(_):
			case SUCCESS:
			{
				for (board in NG.core.scoreBoards)
				{
					boardName.dataSource.add(board.name);
				}
				boardName.selectedIndex = 0;
				loadScores();
			}
		}
	}
	
	function loadScores()
	{
		clearScores();
		
		final board = NG.core.scoreBoards.findByName(boardName.selectedItem);
		final social = this.social.selected;
		board.requestScores
			( size
			, (page-1) * size
			, period
			, social
			, tag.text
			, social ? NG.core.user.name : null
			,	(outcome)->switch outcome
				{
					case FAIL(_)://TODO
					case SUCCESS: onScoresReceive(board.scores);
				}
			);
	}
	
	function clearScores()
	{
		for (i in 0...size)
			scoreList.dataSource.update(i, { rank : " ", user : " ", score: " " });
	}
	
	function onScoresReceive(scores:Array<Score>)
	{
		if (scores.length > size)
			throw 'expected $size scores';
		
		for (i=>score in scores)
		{
			scoreList.dataSource.update(i,
				{ rank : Std.string((page - 1) * size + i + 1)
				, user : score.user.name
				, score: score.formattedValue
				}
			);
		}
	}
}