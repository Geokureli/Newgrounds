package io.newgrounds.components.score;

import io.newgrounds.objects.RawScoreBoardData;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.events.BaseResultData;

typedef PostScoreData = BaseResultData & {
	
	/** The ScoreBoard that was posted to. */
	var scoreboard(default, null):RawScoreBoardData;
	/* The Score that was posted to the board. */
	var score     (default, null):Score;
}
