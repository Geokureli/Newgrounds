package io.newgrounds.net.results.score;

import io.newgrounds.net.data.ScoreBoardData;
import io.newgrounds.net.results.BaseResultData;

typedef GetBoardsResultData = BaseResultData & {
	
	/** An array of ScoreBoard objects. */
	final scoreboards:Array<ScoreBoardData>;
}
