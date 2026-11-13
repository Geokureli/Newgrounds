package ngio.net.results.score;

import ngio.data.ScoreBoardData;
import ngio.net.results.BaseResultData;

typedef GetBoardsResultData = BaseResultData &
{
	/** An array of ScoreBoard objects. */
	final scoreboards:Array<ScoreBoardData>;
}
