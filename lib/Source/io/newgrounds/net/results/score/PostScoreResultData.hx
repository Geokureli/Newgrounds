package io.newgrounds.net.results.score;

import io.newgrounds.net.data.Score;
import io.newgrounds.net.data.ScoreBoardData;
import io.newgrounds.net.results.BaseResultData;

typedef PostScoreResultData = BaseResultData & {
	
	/** The ScoreBoard that was posted to. */
	var scoreboard(default, null):ScoreBoardData;
	/* The Score that was posted to the board. */
	var score     (default, null):Score;
}
