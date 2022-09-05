package io.newgrounds.utils;

import io.newgrounds.objects.Medal;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.ResultType;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.Medal
**/
@:forward
@:access(io.newgrounds.utils.ObjectList)
abstract MedalList (RawMedalList) {
	
	inline public function new (core:NG) {
		
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
	
	public function loadList(?callback:(ResultType)->Void) {
		
		if (checkState(callback) == false)
			return;
		
		_core.calls.medal.getList(_externalAppId)
			.addDataHandler((response)->onMedalsReceived(response))
			.addErrorHandler((e)->fireCallbacks(Error(e.toString())))
			.send();
	}
	
	function onMedalsReceived(response:Response<MedalListResult>) {
		
		if (fireResponseErrors(response))
			return;
		
		var idList:Array<Int> = new Array<Int>();
		
		if (_map == null) {
			
			_map = new Map();
			
			for (medalData in response.result.data.medals) {
				
				var medal = new Medal(_core, medalData);
				_map.set(medal.id, medal);
				idList.push(medal.id);
			}
		} else {
			
			for (medalData in response.result.data.medals) {
				
				_map.get(medalData.id).parse(medalData);
				idList.push(medalData.id);
			}
		}
		
		_core.logVerbose('${response.result.data.medals.length} Medals received [${idList.join(", ")}]');
		
		fireCallbacks(Success);
	}
}

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @see io.newgrounds.objects.Medal
**/
@:forward
@:access(io.newgrounds.utils.ObjectList)
abstract ExternalMedalList (RawMedalList) {
	
	inline public function new (core:NG, externalAppId:String) {
		
		this = new RawMedalList(core, externalAppId);
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