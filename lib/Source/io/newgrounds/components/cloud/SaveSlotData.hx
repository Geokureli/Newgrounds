package io.newgrounds.components.cloud;

import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.BaseResultData;

typedef SaveSlotData = BaseResultData & {
	
	/** The save slot that was changed. */
	var slot(default, null):RawSaveSlot;
}
