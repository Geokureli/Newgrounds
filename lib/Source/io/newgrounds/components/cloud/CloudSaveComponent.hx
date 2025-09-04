package io.newgrounds.components.cloud;

/** Handles loading and saving of game states. */
class CloudSaveComponent extends Component {
	
	/**
	 * Pass into the default value to allow null values.
	 * 
	 * TODO: find less hacky solution
	**/
	static var allowNull:Dynamic = {};
	
	public function new (core){ super(core); }
	
	/**
	 * Deletes all data from a save slot.
	 * 
	 * @param id  The slot number
	**/
	public function clearSlot(id:Int) {
		
		return (makeCall("CloudSave.clearSlot", true): Call<SaveSlotData>)
			.addComponentParameter("id", id);
	}
	
	/**
	 * Returns a specific saveslot object.
	 * 
	 * @param id             The slot number
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function loadSlot(id:Int, externalAppId:String = null) {
		
		return (makeCall("CloudSave.loadSlot", true): Call<SaveSlotData>)
			.addComponentParameter("id", id)
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Returns a list of saveslot objects.
	 * 
	 * @param id             The slot number
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	**/
	public function loadSlots(externalAppId:String = null) {
		
		return (makeCall("CloudSave.loadSlots", true): Call<LoadSlotsData>)
			.addComponentParameter("app_id", externalAppId);
	}
	
	/**
	 * Deletes all data from a save slot.
	 * 
	 * @param data  The data you want to save
	 * @param id    The slot number
	**/
	public function setData(data:String, id:Int) {
		
		return (makeCall("CloudSave.setData", true): Call<SaveSlotData>)
			.addComponentParameter("data", data, allowNull)
			.addComponentParameter("id", id);
	}
}