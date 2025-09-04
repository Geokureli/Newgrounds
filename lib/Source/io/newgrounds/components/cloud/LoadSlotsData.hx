package io.newgrounds.components.cloud;

import io.newgrounds.objects.RawSaveSlotData;
import io.newgrounds.objects.events.BaseResultData;

typedef LoadSlotsData = ExternalAppData & BaseResultData & {
	
	/** An array of SaveSlot objects. */
	var slots(default, null):Array<RawSaveSlotData>;
}