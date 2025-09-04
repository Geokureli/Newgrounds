package io.newgrounds.net.results.cloud;

import io.newgrounds.net.data.SaveSlotData;
import io.newgrounds.net.results.BaseResultData;

typedef LoadSlotsResultData = ExternalAppResultData & BaseResultData & {
	
	/** An array of SaveSlot objects. */
	final slots:Array<SaveSlotData>;
}