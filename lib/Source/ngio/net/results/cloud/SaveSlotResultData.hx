package ngio.net.results.cloud;

import ngio.data.SaveSlotData;
import ngio.net.results.BaseResultData;

typedef SaveSlotResultData = BaseResultData &
{
	/** The save slot that was changed. */
	final slot:SaveSlotData;
}
