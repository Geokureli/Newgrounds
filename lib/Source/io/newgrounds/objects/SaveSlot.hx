package io.newgrounds.objects;

import io.newgrounds.utils.AsyncHttp;
import io.newgrounds.objects.events.Result.SaveSlotResult;
import io.newgrounds.objects.events.Response;

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
	
	public var saveData(default, null):Null<String>;
	
	public function new(core:NGLite, data:RawSaveSlot = null) {
		
		super(core, data);
	}
	
	// override function parse(data:RawMedalData):Void {
		
	// 	super.parse(data);
	// }
	
	public function save(data:String, ?callback:(Null<String>)->Void) {
		
		if (data == null)
			throw "cannot save null to a SaveSlot";
		
		_core.calls.cloudSave.setData(data, id)
			.addDataHandler((response)->setSaveDataOnSlotFetch(response, data, callback))
			.send();
	}
	
	public function clear(?callback:(Null<String>)->Void) {
		
		_core.calls.cloudSave.clearSlot(id)
			.addDataHandler((response)->setSaveDataOnSlotFetch(response, null, callback))
			.send();
	}
	
	public function load(?callback:(Null<String>)->Void) {
		
		_core.calls.cloudSave.loadSlot(id)
			.addDataHandler((response)->loadSaveDataOnSlotFetch(response, callback))
			.send();
	}
	
	function setSaveDataOnSlotFetch(response:Response<SaveSlotResult>, newSaveData:Null<String>, ?callback:(Null<String>)->Void) {
		
		// Always have a non-null callback to avoid having to null check everywhere
		if (callback == null)
			callback = noCallback;
		
		if (response.success && response.result.success) {
			
			var oldTimestamp = timestamp;
			_data = response.result.data.slot;
			saveData = newSaveData;
		}
		
		callback(saveData);
	}
	
	inline function mergeSaveSlotData(response:Response<SaveSlotResult>) {
		
		if (response.success && response.result.success)
			_data = response.result.data.slot;
	}
	
	function loadSaveDataOnSlotFetch(response:Response<SaveSlotResult>, ?callback:(Null<String>)->Void) {
		
		// Always have a non-null callback to avoid having to null check everywhere
		if (callback == null)
			callback = noCallback;
			
		var oldTimestamp = timestamp;
		mergeSaveSlotData(response);
		
		if (saveData == null || timestamp != oldTimestamp)
		{
			loadData(callback);
			return;
		}
		
		callback(saveData);
	}
	
	function loadData(callback:(Null<String>)->Void) {
		
		if (url == null) {
			
			callback(null);
			return;
		}
		
		// TODO: load data (async)
		AsyncHttp.send(url, null,
			(s)->
			{
				saveData = s;
				callback(saveData);
			},
			(error)->callback(saveData),
			(status)->{}// do nothing, TODO: optional?
		);
	}
	
	static function noCallback(s:Null<String>){}
}