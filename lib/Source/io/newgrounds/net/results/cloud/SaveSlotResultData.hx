package io.newgrounds.net.results.cloud;

import io.newgrounds.net.data.SaveSlotData;
import io.newgrounds.net.results.BaseResultData;

typedef SaveSlotResultData = BaseResultData & {
	
	/** The save slot that was changed. */
	final slot:SaveSlotData;
}
