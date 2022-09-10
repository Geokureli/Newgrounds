package io.newgrounds.objects;

import io.newgrounds.Call;
import io.newgrounds.utils.AsyncHttp;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Outcome;
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
	
	var _externalAppId(default, null):String;
	
	public function new(core:NGLite, data:RawSaveSlot = null, externalAppId:String = null) {
		
		_externalAppId = externalAppId;
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
	public function save(data:String, ?callback:(Outcome<CallError>)->Void) {
		
		if (data == null)
			throw "cannot save null to a SaveSlot";
		
		if (_externalAppId != null)
			throw "cannot save to an external app";
		
		_core.calls.cloudSave.setData(data, id)
			.addOutcomeHandler(setContentsOnSlotFetch.bind(_, data, callback))
			.send();
	}
	
	/**
	 * Clears cloud save slot
	 * 
	 * @param callback  Called when the data is cleared.
	 *                  Tells whether the server call was successful.
	 */
	public function clear(?callback:(Outcome<CallError>)->Void) {
		
		if (_externalAppId != null)
			throw "cannot clear an external app's save slot";
		
		_core.calls.cloudSave.clearSlot(id)
			.addOutcomeHandler((outcome)->setContentsOnSlotFetch(outcome, null, callback))
			.send();
	}
	
	function setContentsOnSlotFetch
	( outcome:CallOutcome<SaveSlotData>
	, contents:Null<String>
	, ?callback:(Outcome<CallError>)->Void
	) {
		
		switch (outcome) {
			
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
				
				this.contents = contents;
				parse(data.slot);
				callback.safe(SUCCESS);
				onUpdate.dispatch();
		}
	}
	
	/**
	 * Loads the save slot's file contents
	 * 
	 * @param callback  Called when the save file is loaded.
	 *                  Returns the contents, is successful, otherwise returns an error.
	 */
	public function update(?callback:(Outcome<CallError>)->Void) {
		
		_core.calls.cloudSave.loadSlot(id, _externalAppId)
			.addOutcomeHandler(onUpdateFetch.bind(_, callback))
			.send();
	}
	
	function onUpdateFetch
	( outcome:CallOutcome<SaveSlotData>
	, ?callback:(Outcome<CallError>)->Void
	) {
		
		switch (outcome) { 
			
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
				
				parse(data.slot);
				callback.safe(SUCCESS);
				onUpdate.dispatch();
		}
	}
	
	/**
	 * Loads the save slot's file contents
	 * 
	 * @param callback  Called when the save file is loaded.
	 *                  Returns the contents, is successful, otherwise returns an error.
	 */
	public function load(?callback:(SaveSlotOutcome)->Void) {
		
		if (isEmpty())
			throw 'Cannot load from an empty SaveSlot, id:$id';
		
		AsyncHttp.send(url, null,
			(s)->
			{
				contents = s;
				callback.safe(SUCCESS(contents));
				onUpdate.dispatch();
			},
			(error)->callback.safe(FAIL(HTTP(error)))
		);
	}
	
	/** Whether any data has been saved to this slot. */
	inline public function isEmpty():Bool return url == null;
	
	inline static var MB = KB * 1000;
	inline static var KB = 1000;
	/** Displays the slot's size in either bytes, kB or MB */
	public function prettyPrintSize() {
		
		if (size > MB) return Std.string(Math.ceil(size / MB * 10) / 10) + " MB";
		
		if (size > KB) return Std.string(Math.ceil(size / KB * 10) / 10) + " kB";
		
		return Std.string(size) + " bytes";
	}
	
	public function getDate() {
		
		return Date.fromTime(timestamp * 1000);
	}
}

typedef SaveSlotOutcome = TypedOutcome<Null<String>, CallError>;