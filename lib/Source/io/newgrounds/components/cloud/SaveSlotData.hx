package io.newgrounds.components.cloud;

import io.newgrounds.objects.RawSaveSlotData;
import io.newgrounds.objects.events.BaseResultData;

typedef SaveSlotData = BaseResultData & {
	
	/** The save slot that was changed. */
	var slot(default, null):RawSaveSlotData;
}
