package io.newgrounds.components;

import io.newgrounds.objects.events.Result.SaveSlotResult;
import io.newgrounds.objects.events.Result.LoadSlotsResult;
import io.newgrounds.NGLite;

class CloudSaveComponent extends Component {
	
	/**
	 * Pass into the default value to allow null values.
	 * 
	 * TODO: find less hacky solution
	 */
	static var allowNull:Dynamic = {};
	
	public function new (core:NGLite){ super(core); }
	
	public function clearSlot(id:Int):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.clearSlot", true)
			.addComponentParameter("id", id);
	}
	
	public function loadSlot(id:Int):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.loadSlot", true)
			.addComponentParameter("id", id);
	}
	
	public function loadSlots():Call<LoadSlotsResult> {
		
		return new Call<LoadSlotsResult>(_core, "CloudSave.loadSlots", true);
	}
	
	public function setData(data:String, id:Int):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.setData", true)
			.addComponentParameter("data", data, allowNull)
			.addComponentParameter("id", id);
	}
}