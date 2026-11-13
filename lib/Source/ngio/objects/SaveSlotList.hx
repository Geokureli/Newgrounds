package ngio.objects;

import ngio.data.SaveSlotData;
import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Error;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.cloud.LoadSlotsResultData;
import ngio.objects.SaveSlot;

using ngio.net.Outcome.OutcomeTools;
using ngio.net.Outcome.TypedOutcomeTools;

/**
 * A list of cloud save slots
 * 
 * To use an individual slot, first call `loadList` to populate the list.
 * 
 * @see ngio.objects.SaveSlot
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract SaveSlotList (RawSaveSlotList)
{
	inline public function new (core)
	{
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
@:access(ngio.objects.SaveSlot)
private class RawSaveSlotList extends ObjectList<Int, SaveSlot>
{
	public var length(get, never):Int;
	inline function get_length() return _ordered == null ? 0 : _ordered.length;
	
	var _ordered:Array<SaveSlot>;
	
	/** return the slot with the specified 0-based order that was sent from the server. */
	inline public function getOrdered(i:Int)
	{
		return _ordered[i];
	}
	
	/**
	 * Loads the info for each cloud save slot, including the last save time and size
	 * 
	 * @param callback   Whether the request was successful, or an error message.
	 */
	public function loadList(?callback:(Outcome<CallError>)->Void)
	{
		if (_core.appData.sessionId == null)
			throw "Must be logged in to request cloud saves";
		
		if (checkState(callback) == false)
			return;
		
		_core.calls.cloudSave.loadSlots()
			.addOutcomeHandler(onSaveSlotsReceived)
			.send();
	}
	
	function onSaveSlotsReceived(outcome:CallOutcome<LoadSlotsResultData>)
	{
		switch(outcome)
		{
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
				
				for (slotData in data.slots) 
					parse(slotData);
				
				_core.logger.logVerbose('${data.slots.length} SaveSlots received ${data.slots.map(s->s.id)}');
				
				fireCallbacks(SUCCESS);
		}
	}
	
	function parse(data:SaveSlotData)
	{
		if (_map.exists(data.id))
			_map[data.id].parse(data);
		else {
			
			add(new SaveSlot(_core, data));
		}
	}
	
	function add(slot:SaveSlot)
	{
		_map[slot.id] = slot;
		_ordered.push(slot);
	}
	
	/**
	 * Loads the save file of every available slot.  If any slot info hasn't been loaded yet,
	 * it will load that first.
	**/
	public function loadAllFiles(?callback:(Outcome<CallError>)->Void)
	{
		if (_map == null) {
			
			// populate the save slots first
			loadList((outcome)->switch (outcome)
			{
				case SUCCESS    : loadAllFiles(callback);
				case FAIL(error): callback.safe(FAIL(error));
			});
			return;
		}
		
		var slotsToLoad = 0;
		var outcome:Outcome<CallError> = SUCCESS;
		function onSlotLoad(slotOutcome:SaveSlotOutcome)
		{
			// If this is the first error, store it
			if (outcome == SUCCESS)
			{
				switch (slotOutcome)
				{
					case SUCCESS(_):
					case FAIL(e):
						outcome = FAIL(e);
				}
			}
			
			// count the completed slots, call the callback when we're done
			slotsToLoad--;
			if (slotsToLoad == 0)
				callback.safe(outcome);
		}
		
		/**
		 * Count the slots, first, then try to load. these load calls may be threaded,
		 * so this may be neccesary to avoid multiple callbacks.
		**/ 
		for (slot in _map)
		{
			if (slot.isEmpty() == false)
				slotsToLoad++;
		}
		
		if (slotsToLoad == 0)
		{
			callback.safe(SUCCESS);
			return;
		}
		
		for (slot in _map)
		{
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
 * @see ngio.objects.SaveSlot
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract ExternalSaveSlotList (RawSaveSlotList)
{
	inline public function new (core)
	{
		this = new RawSaveSlotList(core);
	}
	
	/** Typically the id is the slot's 1-based order that was sent from the server. */
	@:arrayAccess
	inline public function getById(id:Int):ExternalSaveSlot return this._map.get(id);
}

@:forward
abstract ExternalSaveSlot(SaveSlot) from SaveSlot
{
	/** Hides the underlying function. */
	function save() {}
	
	/** Hides the underlying function. */
	function clear() {}
}