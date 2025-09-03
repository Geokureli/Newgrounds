package io.newgrounds.components.score;

import io.newgrounds.objects.RawScoreBoardData;
import io.newgrounds.objects.events.BaseResultData;

typedef GetBoardsData = BaseResultData & {
	
	/** An array of ScoreBoard objects. */
	final scoreboards:Array<RawScoreBoardData>;
}
