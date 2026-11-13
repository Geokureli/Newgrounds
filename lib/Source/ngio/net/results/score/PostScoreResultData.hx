package ngio.net.results.score;

import ngio.data.ScoreBoardData;
import ngio.data.ScoreData;
import ngio.net.results.BaseResultData;

typedef PostScoreResultData = BaseResultData &
{
	/** The ScoreBoard that was posted to. */
	final scoreboard:ScoreBoardData;
	
	/* The Score that was posted to the board. */
	final score     :ScoreData;
}
