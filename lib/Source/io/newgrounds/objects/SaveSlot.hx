package io.newgrounds.objects;

import io.newgrounds.utils.AsyncHttp;
import io.newgrounds.objects.events.Result.SaveSlotResult;
import io.newgrounds.objects.events.ResultType;
import io.newgrounds.objects.events.Response;

/**
 * Contains information about a CloudSave slot.
**/
typedef RawSaveSlot = {
	
	/** A date and time (in ISO 8601 format) representing when this slot was last saved. */
	var datetime :Null<String>;
	/** The slot number. */
	var id       :Int;
	/** The size of the save data in bytes. */
	var size     :Int;
	/** A unix timestamp representing when this slot was last saved. */
	var timestamp:Int;
	/** The URL containing the actual save data for this slot, or null if this slot has no data. */
	var url      :Null<String>;
}

/**
 * Contains information about a CloudSave slot.
 * 
 * This is helper class that lets you call methods directly on the slot object, rather than
 * calling generic calls using the slot's id number.
**/
class SaveSlot extends Object<RawSaveSlot>
{
	/** A date and time (in ISO 8601 format) representing when this slot was last saved. */
	public var datetime(get, never):Null<String>;
	
	/** The slot number. */
	public var id(get, never):Int;
	
	/** The size of the save data in bytes. */
	public var size(get, never):Int;
	
	/** A unix timestamp representing when this slot was last saved. */
	public var timestamp(get, never):Int;
	
	/** The URL containing the actual save data for this slot, or null if this slot has no data. */
	public var url(get, never):Null<String>;
	
	inline function get_datetime () return _data.datetime;
	inline function get_id       () return _data.id;
	inline function get_size     () return _data.size;
	inline function get_timestamp() return _data.timestamp;
	inline function get_url      () return _data.url;
	
	/** The contents of this slot's save file. */
	public var saveData(default, null):Null<String>;
	
	public function new(core:NGLite, data:RawSaveSlot = null) {
		
		super(core, data);
	}
	
	/**
	 * Saves the supplied data to the cloud save slot
	 * 
	 * @param data      The data to save to the slot
	 * @param callback  Called when the data is saved with the new value.
	 *                  Tells whether the server call was successful.
	 * 
	 * @throws Exception if data is null
	 */
	public function save(data:String, ?callback:(ResultType)->Void) {
		
		if (data == null)
			throw "cannot save null to a SaveSlot";
		
		_core.calls.cloudSave.setData(data, id)
			.addDataHandler((response)->setSaveDataOnSlotFetch(response, data, callback))
			.send();
	}
	
	/**
	 * Clears cloud save slot
	 * 
	 * @param callback  Called when the data is cleared.
	 *                  Tells whether the server call was successful.
	 */
	public function clear(?callback:(ResultType)->Void) {
		
		_core.calls.cloudSave.clearSlot(id)
			.addDataHandler((response)->setSaveDataOnSlotFetch(response, null, callback))
			.send();
	}
	
	/**
	 * Clears cloud save slot
	 * 
	 * @param callback  Called when the data is cleared.
	 *                  Returns the saveData, is successful, otherwise returns an error.
	 */
	public function load(?callback:(SaveSlotResultType)->Void) {
		
		_core.calls.cloudSave.loadSlot(id)
			.addDataHandler((response)->loadSaveDataOnSlotFetch(response, callback))
			.send();
	}
	
	function setSaveDataOnSlotFetch(response:Response<SaveSlotResult>, newSaveData:Null<String>, ?callback:(ResultType)->Void) {
		
		// Always have a non-null callback to avoid having to null check everywhere
		if (callback == null)
			callback = (_)->{};
		
		if (response.success && response.result.success) {
			
			var oldTimestamp = timestamp;
			parse(response.result.data.slot);
			saveData = newSaveData;
		}
		
		callback(Success);
	}
	
	inline function mergeSaveSlotData(response:Response<SaveSlotResult>) {
		
		if (response.success && response.result.success)
			parse(response.result.data.slot);
	}
	
	function loadSaveDataOnSlotFetch(response:Response<SaveSlotResult>, ?callback:(SaveSlotResultType)->Void) {
		
		// Always have a non-null callback to avoid having to null check everywhere
		if (callback == null)
			callback = (_)->{};
			
		var oldTimestamp = timestamp;
		mergeSaveSlotData(response);
		
		if (saveData == null || timestamp != oldTimestamp)
		{
			loadData(callback);
			return;
		}
		
		callback(Success(saveData));
	}
	
	function loadData(callback:(SaveSlotResultType)->Void) {
		
		if (url == null) {
			
			callback(Success(null));
			return;
		}
		
		// TODO: load data (async)
		AsyncHttp.send(url, null,
			(s)->
			{
				saveData = s;
				callback(Success(saveData));
			},
			(error)->callback(Error(error))
		);
	}
}

typedef SaveSlotResultType = TypedResultType<Null<String>>;