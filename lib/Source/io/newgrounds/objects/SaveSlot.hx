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
	
	/** The contents of this slot's save file. Will be null until `load` is called. **/
	public var contents(default, null):Null<String>;
	
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
			.addDataHandler((response)->setContentsOnSlotFetch(response, data, callback))
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
			.addDataHandler((response)->setContentsOnSlotFetch(response, null, callback))
			.send();
	}
	
	function setContentsOnSlotFetch
	( response:Response<SaveSlotResult>
	, contents:Null<String>
	, ?callback:(ResultType)->Void
	) {
		
		// Always have a non-null callback to avoid having to null check everywhere
		if (callback == null)
			callback = (_)->{};
		
		if (response.success && response.result.success) {
			
			this.contents = contents;
			parse(response.result.data.slot);
		}
		
		callback(Success);
	}
	
	/**
	 * Loads the save slot's file contents
	 * 
	 * @param callback  Called when the save file is loaded.
	 *                  Returns the contents, is successful, otherwise returns an error.
	 */
	public function load(?callback:(SaveSlotResultType)->Void) {
		
		if (isEmpty())
			throw 'Cannot load from an empty SaveSlot, id:$id';
		
		// TODO: load data (async)
		AsyncHttp.send(url, null,
			(s)->
			{
				contents = s;
				callback(Success(contents));
				onUpdate.dispatch();
			},
			(error)->callback(Error(error))
		);
	}
	
	/** Whether any data has been saved to this slot. */
	inline public function isEmpty():Bool return url == null;
}

typedef SaveSlotResultType = TypedResultType<Null<String>>;