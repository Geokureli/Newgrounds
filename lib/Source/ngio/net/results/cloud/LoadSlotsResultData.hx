package ngio.net.results.cloud;

import ngio.data.SaveSlotData;
import ngio.net.results.BaseResultData;

typedef LoadSlotsResultData = ExternalAppResultData & BaseResultData &
{
	/** An array of SaveSlot objects. */
	final slots:Array<SaveSlotData>;
}