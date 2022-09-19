package io.newgrounds.components;

import io.newgrounds.objects.events.Result.SaveSlotResult;
import io.newgrounds.objects.events.Result.LoadSlotsResult;
import io.newgrounds.NGLite;

/** Handles loading and saving of game states. */
class CloudSaveComponent extends Component {
	
	/**
	 * Pass into the default value to allow null values.
	 * 
	 * TODO: find less hacky solution
	**/
	static var allowNull:Dynamic = {};
	
	public function new (core:NGLite){ super(core); }
	
	/**
	 * Deletes all data from a save slot.
	 * 
	 * @param id  The slot number
	**/
	public function clearSlot(id:Int):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.clearSlot", true)
			.addComponentParameter("id", id);
	}
	
	/**
	 * Returns a specific saveslot object.
	 * 
	 * @param id             The slot number
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function loadSlot(id:Int, externalAppId:String = null):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.loadSlot", true)
			.addComponentParameter("id", id)
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Returns a list of saveslot objects.
	 * 
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function loadSlots(externalAppId:String = null):Call<LoadSlotsResult> {
		
		return new Call<LoadSlotsResult>(_core, "CloudSave.loadSlots", true)
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Deletes all data from a save slot.
	 * 
	 * @param data  The data you want to save
	 * @param id    The slot number
	**/
	public function setData(data:String, id:Int):Call<SaveSlotResult> {
		
		return new Call<SaveSlotResult>(_core, "CloudSave.setData", true)
			.addComponentParameter("data", data, allowNull)
			.addComponentParameter("id", id);
	}
}