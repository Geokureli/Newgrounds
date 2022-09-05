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
@:access(io.newgrounds.utils.ObjectList)
abstract SaveSlotList (RawSaveSlotList) {
	
	inline public function new (core:NG) {
		
		this = new RawSaveSlotList(core);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int) return this._map.get(id);
}

/**
 * Note: `SaveSlotList` is just an abstract wrapper of `RawSaveSlotList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:access(io.newgrounds.objects.SaveSlot)
class RawSaveSlotList extends ObjectList<Int, SaveSlot> {
	
	public var length(get, never):Int;
	inline function get_length() return _ordered == null ? 0 : _ordered.length;
	
	var _ordered:Array<SaveSlot>;
	
	/** return the slot with the specified 0-based order that was sent from the server. */
	inline public function getOrdered(i:Int) {
		
		return _ordered[i];
	}
	
	public function loadList(loadFiles = false, ?callback:(ResultType)->Void) {
		
		if (checkState(callback, true) == false)
			return;
		
		_core.calls.cloudSave.loadSlots(_externalAppId)
			.addDataHandler((response)->onSaveSlotsReceived(response, loadFiles))
			.addErrorHandler((e)->fireCallbacks(Error(e.toString())))
			.send();
	}
	
	function onSaveSlotsReceived(response:Response<LoadSlotsResult>, loadFiles:Bool) {
		
		if (fireResponseErrors(response))
			return;
		
		var idList:Array<Int> = new Array<Int>();
		
		if (_map == null) {
			
			_map = new Map();
			_ordered = [];
		}
		
		for (slotData in response.result.data.slots) {
			
			var id = slotData.id;
			if (_map.exists(id) == false) {
				
				var slot = new SaveSlot(_core, slotData);
				_map.set(id, slot);
				_ordered.push(slot);
				
			} else
				_map[id].parse(slotData);
			
			idList.push(id);
		}
		
		_core.logVerbose('${idList.length} SaveSlots received [${idList.join(", ")}]');
		
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
		
		if (_map == null) {
			
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
		for (slot in _map) {
			
			if (slot.isEmpty() == false)
				slotsToLoad++;
		}
		
		if (slotsToLoad == 0)
		{
			callback(Success);
			return;
		}
		
		for (slot in _map) {
			
			if (slot.isEmpty() == false)
				slot.load(onSlotLoad);
		}
	}
}

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.SaveSlot
**/
@:forward
@:access(io.newgrounds.utils.ObjectList)
abstract ExternalSaveSlotList (RawSaveSlotList) {
	
	inline public function new (core:NG, externalAppId:String) {
		
		this = new RawSaveSlotList(core, externalAppId);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int):ExternalSaveSlot return this._map.get(id);
}

@:forward
abstract ExternalSaveSlot(SaveSlot) from SaveSlot {
	
	/** Hides the underlying function. */
	function save() {}
	
	/** Hides the underlying function. */
	function clear() {}
}