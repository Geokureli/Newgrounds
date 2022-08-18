package io.newgrounds.utils;

import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.ResultType;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;

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
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int) return this.map.get(id);
}

/**
 * Note: `SaveSlotList` is just an abstract wrapper of `RawSaveSlotList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:allow(io.newgrounds.utils.SaveSlotList)
@:access(io.newgrounds.objects.SaveSlot)
class RawSaveSlotList {
	
	public var state(default, null):SaveSlotListState = Empty;
	public var length(get, never):Int;
	inline function get_length() return ordered == null ? 0 : ordered.length;
	
	var core:NG;
	var map:Map<Int, SaveSlot>;
	var ordered:Array<SaveSlot>;
	
	var callbacks = new TypedDispatcher<ResultType>();
	
	public function new (core:NG) {
		
		this.core = core;
	}
	
	/** return the slot with the specified 0-based order that was sent from the server. */
	inline public function getOrdered(i:Int)
	{
		return ordered[i];
	}
	
	public function loadList(loadFiles = false, ?callback:(ResultType)->Void) {
		
		if (NG.core.loggedIn == false) {
			
			if (callback != null)
				callback(Error("Must be logged in to request cloud saves"));
			
			return;
		}
		
		switch(state)
		{
			case Loaded:
				
				if (callback != null)
					callback(Success);
				
				return;
				
			case Empty: state = Loading;
			case Loading:
		}
		
		if (callback != null)
			callbacks.add(callback);
		
		core.calls.cloudSave.loadSlots()
			.addDataHandler((response)->onSaveSlotsReceived(response, loadFiles))
			.addErrorHandler((e)->fireCallbacks(Error(e.toString())))
			.send();
	}
	
	function fireCallbacks(result:ResultType) {
		
		if (result.match(Error(_)))
			state = Empty;
		else
			state = Loaded;
		
		callbacks.dispatch(result);
		
		if (result.match(Success))
			core.onSaveSlotsLoaded.dispatch();
	}
	
	function onSaveSlotsReceived(response:Response<LoadSlotsResult>, loadFiles:Bool) {
		
		if (!response.success)
		{
			fireCallbacks(Error(response.error.toString()));
			return;
		}
		
		if (!response.result.success)
		{
			fireCallbacks(Error(response.result.error.toString()));
			return;
		}
		
		var idList:Array<Int> = new Array<Int>();
		
		if (map == null) {
			
			map = new Map();
			ordered = [];
		}
		
		for (slotData in response.result.data.slots) {
			
			var id = slotData.id;
			if (map.exists(id) == false) {
				
				var slot = new SaveSlot(core, slotData);
				map.set(id, slot);
				ordered.push(slot);
				
			} else
				map[id].parse(slotData);
			
			idList.push(id);
		}
		
		core.logVerbose('${idList.length} SaveSlots received [${idList.join(", ")}]');
		
		if (loadFiles) {
			
			// delay onSaveSlotsLoaded.dispatch() until save data is loaded
			loadAllFiles(fireCallbacks);
			
		} else { 
			
			fireCallbacks(Success);
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
	public inline function iterator() return ordered.iterator();

	/**
	 * Returns an Iterator over the ids and values of `this` list.
	 * 
	 * The order is undefined.
	**/
	public inline function keyValueIterator() return map.keyValueIterator();
	
	static function noCallback(r:ResultType){}
}

enum SaveSlotListState {
	
	Empty;
	Loading;
	Loaded;
}