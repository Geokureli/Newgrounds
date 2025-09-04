package io.newgrounds.lists;

import io.newgrounds.net.Call;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.Result;
import io.newgrounds.net.results.medal.MedalListResultData;
import io.newgrounds.net.results.medal.MedalUnlockResultData;
import io.newgrounds.objects.Medal;
import io.newgrounds.utils.Dispatcher;

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @seeio.newgrounds.objects.Medal
**/
@:forward
@:access(io.newgrounds.lists.ObjectList)
abstract MedalList (RawMedalList) {
	
	inline public function new (core) {
		
		this = new RawMedalList(core);
	}
	
	/** Returns the medal with the matching id. */
	@:arrayAccess
	inline public function getById(id:Int) return this._map.get(id);
	
	/** Returns the medal with the matching name. */
	@:arrayAccess
	public function getByName(name:String) {
		
		for (medal in this._map) {
			
			if (medal.name == name)
				return medal;
		}
		
		return null;
	}
}

@:access(io.newgrounds.objects.Medal)
class RawMedalList extends ObjectList<Int, Medal> {
	
	public function loadList(?callback:(Outcome<CallError>)->Void) {
		
		if (checkState(callback) == false)
			return;
		
		_core.calls.medal.getList()
			.addOutcomeHandler(onMedalsReceived)
			.send();
	}
	
	// @:access(io.newgrounds.objects.Medal.onUnlockCalled)
	function onMedalsReceived(outcome:CallOutcome<MedalListResultData>) {
		
		switch(outcome) {
			
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
				
				final idList:Array<Int> = new Array<Int>();
				
				if (_map == null) {
					
					_map = new Map();
					
					for (medalData in data.medals) {
						
						final medal = new Medal(medalData);
						_map.set(medal.id, medal);
						idList.push(medal.id);
						
						medal.onUnlockCalled.add(function (callback)
						{
							_core.calls.medal.unlock(medal.id)
								.addOutcomeHandler(callback)
								.send();
						});
					}
				} else {
					
					for (medalData in data.medals) {
						
						_map.get(medalData.id).parse(medalData);
						idList.push(medalData.id);
					}
				}
				
				_core.logger.logVerbose('${data.medals.length} Medals received [${idList.join(", ")}]');
				
				fireCallbacks(SUCCESS);
		}
	}
}

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @seeio.newgrounds.objects.Medal
**/
@:forward
@:access(io.newgrounds.lists.ObjectList)
abstract ExternalMedalList (RawMedalList) {
	
	inline public function new (core) {
		
		this = new RawMedalList(core);
	}
	
	/** Returns the medal with the matching id. */
	@:arrayAccess
	inline public function getById(id:Int):Null<ExternalMedal> return this._map.get(id);
	
	/** Returns the medal with the matching name. */
	@:arrayAccess
	public function getByName(name:String):Null<ExternalMedal> {
		
		for (medal in this._map) {
			
			if (medal.name == name)
				return medal;
		}
		
		return null;
	}
}

@:forward
abstract ExternalMedal(Medal) from Medal {
	
	/** Hides the underlying function. */
	function sendUnlock() {}
	
	/** Hides the underlying function. */
	function sendDebugUnlock() {}
}