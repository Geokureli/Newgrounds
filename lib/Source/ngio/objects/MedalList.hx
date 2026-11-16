package ngio.objects;

import ngio.data.MedalData;
import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Error;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.Result;
import ngio.net.results.medal.MedalListResultData;
import ngio.net.results.medal.MedalUnlockResultData;
import ngio.objects.Medal;

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @see ngio.objects.Medal
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract MedalList (RawMedalList)
{
	inline public function new (core)
	{
		this = new RawMedalList(core);
	}
	
	/** Returns the medal with the matching id. */
	@:arrayAccess
	inline public function getById(id:Int) return this._map.get(id);
	
	/** Returns the medal with the matching name. */
	@:arrayAccess
	public function getByName(name:String)
	{
		for (medal in this._map)
		{
			if (medal.name == name)
				return medal;
		}
		
		return null;
	}
}

@:access(ngio.objects.Medal)
class RawMedalList extends ObjectList<Int, Medal>
{
	public function loadList(?callback:(Outcome<CallError>)->Void)
	{
		if (checkState(callback) == false)
			return;
		
		_core.calls.medal.getList()
			.addOutcomeHandler(onMedalsReceived)
			.send();
	}
	
	// @:access(ngio.objects.Medal.onUnlockCalled)
	function onMedalsReceived(outcome:CallOutcome<MedalListResultData>)
	{
		switch(outcome)
		{
			case FAIL(error): fireCallbacks(FAIL(error));
			case SUCCESS(data):
					
				for (medalData in data.medals)
					parse(medalData);
				
				_core.logger.logVerbose('${data.medals.length} Medals received ${data.medals.map(m->m.id)}');
				
				fireCallbacks(SUCCESS);
		}
	}
	
	function parse(data:MedalData)
	{
		if (_map.exists(data.id))
			_map[data.id].parse(data);
		else
			add(new Medal(data));
	}
	
	function add(medal:Medal)
	{
		_map[medal.id] = medal;
		
		medal.onUnlockCalled.add(function (callback)
		{
			_core.calls.medal.unlock(medal.id)
				.addOutcomeHandler(callback)
				.send();
		});
	}
}

/**
 * A list of Medals
 * 
 * To use, first call `loadList` to populate the list.
 * 
 * @see ngio.objects.Medal
**/
@:forward
@:access(ngio.objects.ObjectList)
abstract ExternalMedalList (RawMedalList)
{
	inline public function new (core)
	{
		this = new RawMedalList(core);
	}
	
	/** Returns the medal with the matching id. */
	@:arrayAccess
	inline public function getById(id:Int):Null<ExternalMedal> return this._map.get(id);
	
	/** Returns the medal with the matching name. */
	@:arrayAccess
	public function getByName(name:String):Null<ExternalMedal>
	{
		for (medal in this._map)
		{
			if (medal.name == name)
				return medal;
		}
		
		return null;
	}
}

@:forward
abstract ExternalMedal(Medal) from Medal
{
	/** Hides the underlying function. */
	function sendUnlock() {}
	
	/** Hides the underlying function. */
	function sendDebugUnlock() {}
}