package io.newgrounds.utils;

import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.ResultType;
import io.newgrounds.objects.events.Result;

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.SaveSlot
**/
@:forward
abstract SaveSlotList (RawSaveSlotList)
{
	inline public function new (core:NG)
	{
		this = new RawSaveSlotList(core);
	}
	
	@:arrayAccess
	inline public function get(id:Int) return this.map.get(id);
}

/**
 * Note: `SaveSlotList` is just an abstract wrapper of `RawSaveSlotList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:allow(io.newgrounds.utils.SaveSlotList)
@:access(io.newgrounds.objects.SaveSlot)
class RawSaveSlotList {
	
	var core:NG;
	var map:Map<Int, SaveSlot>;
	
	public function new (core:NG) {
		
		this.core = core;
	}
	
	public function loadList(loadFiles = false, ?callback:(ResultType)->Void) {
		
		if (callback == null)
			callback = noCallback;
		
		core.calls.cloudSave.loadSlots()
			.addDataHandler((response)->onSaveSlotsReceived(response, loadFiles, callback))
			.addErrorHandler((e)->callback(Error(e.toString())))
			.send();
	}
	
	function onSaveSlotsReceived
	( response:Response<LoadSlotsResult>
	, loadFiles:Bool
	, callback:(ResultType)->Void
	) {
		
		if (!response.success)
		{
			callback(Error(response.error.toString()));
			return;
		}
		
		if (!response.result.success)
		{
			callback(Error(response.result.error.toString()));
			return;
		}
		
		var idList:Array<Int> = new Array<Int>();
		
		if (map == null)
			map = new Map();
		
		for (slotData in response.result.data.slots) {
			
			var id = slotData.id;
			if (map.exists(id) == false) {
				
				var slot = new SaveSlot(core, slotData);
				map.set(id, slot);
				
			} else
				map[id].parse(slotData);
			
			idList.push(id);
		}
		
		core.logVerbose('${idList.length} SaveSlots received [${idList.join(", ")}]');
		
		if (loadFiles) {
			
			// delay onSaveSlotsLoaded.dispatch() until save data is loaded
			loadAllFiles(function (result:ResultType) {
				
				callback(result);
				core.onSaveSlotsLoaded.dispatch();
			});
			
		} else {
			
			callback(Success);
			core.onSaveSlotsLoaded.dispatch();
		}
	}
	
	/**
	 * Loads the save file of every available slot.  If any slot info hasn't been loaded yet,
	 * it will load that first.
	**/
	public function loadAllFiles(callback:(ResultType)->Void) {
		
		if (map == null) {
			
			// populate the save slots first
			loadList(true, callback);
			return;
		}
		
		var slotsToLoad = 0;
		var result:ResultType = Success;
		function onSlotLoad(slotResult:SaveSlotResultType) {
			
			// If this is the first error, store it
			if (result == Success) {
				
				switch (slotResult) {
					
					case Success(_):
					case Error(e):
						result = Error(e);
				}
			}
			
			// count the completed slots, call the callback when we're done
			slotsToLoad--;
			if (slotsToLoad == 0)
				callback(result);
		}
		
		/**
		 * Count the slots, first, then try to load. these load calls may be threaded,
		 * so this may be neccesary to avoid multiple callbacks.
		**/ 
		for (slot in map) {
			
			if (slot.isEmpty() == false)
				slotsToLoad++;
		}
		
		if (slotsToLoad == 0)
		{
			callback(Success);
			return;
		}
		
		for (slot in map) {
			
			if (slot.isEmpty() == false)
				slot.load(onSlotLoad);
		}
	}
	
	/**
	 * Returns an Iterator over the ids of `this` list.
	 * 
	 * The order of ids is undefined.
	**/
	public inline function keys() return map.keys();
	
	/**
	 * Returns an Iterator over the values of `this` list.
	 * 
	 * The order of values is undefined.
	**/
	public inline function iterator() return map.iterator();

	/**
	 * Returns an Iterator over the ids and values of `this` list.
	 * 
	 * The order is undefined.
	**/
	public inline function keyValueIterator() return map.keyValueIterator();
	
	static function noCallback(r:ResultType){}
}