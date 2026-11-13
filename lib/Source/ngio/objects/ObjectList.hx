package ngio.objects;

import ngio.cores.CallableCore;
import ngio.data.AppData;
import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Error;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.Result;
import ngio.objects.SaveSlot;

using ngio.net.Outcome.OutcomeTools;
using ngio.net.Outcome.TypedOutcomeTools;

class ObjectList<K:Int, V>
{
	public var state(default, null):ListState = Empty;
	
	/**
	 * Called after `loadList` successfully populates this list, for the first time.
	 */
	public var onLoad(default, null) = new Dispatcher();
	
	final _core:CallableCore;
	final _map = new Map<K, V>();
	
	final _callbacks = new TypedDispatcher<Outcome<CallError>>();
	
	public function new (core:CallableCore)
	{
		_core = core;
	}
	
	public function clear()
	{
		_map.clear();
		_callbacks.clear();
	}
	
	inline public function get(id:K):V return _map.get(id);
	
	function checkState(callback:Null<(Outcome<CallError>)->Void>, allowReload = true):Bool
	{
		inline function addCallback()
		{
			if (callback != null)
				_callbacks.addOnce(callback);
		}
		
		switch(state)
		{
			case Loaded:
			{
				if (allowReload)
				{
					addCallback();
					return true;
				}
				
				callback.safe(SUCCESS);
				
				return false;
			}
			case Empty:
			{
				state = Loading;
				addCallback();
				return true;
			}
			case Loading:
			{
				addCallback();
				return false;
			}
		}
	}
	
	function fireCallbacks(outcome:Outcome<CallError>)
	{
		final firstFire = state != Loaded;
		
		if (firstFire && outcome.match(FAIL(_)))
			state = Empty;
		else
			state = Loaded;
		
		_callbacks.dispatch(outcome);
		
		if (firstFire && outcome.match(SUCCESS))
			onLoad.dispatch();
	}
	
	/**
	 * Returns an Iterator over the ids of `this` list.
	 * 
	 * The order of ids is undefined.
	**/
	public inline function keys() return _map.keys();
	
	/**
	 * Returns an Iterator over the values of `this` list.
	 * 
	 * The order of values is undefined.
	**/
	public inline function iterator() return _map.iterator();

	/**
	 * Returns an Iterator over the ids and values of `this` list.
	 * 
	 * The order is undefined.
	**/
	public inline function keyValueIterator() return _map.keyValueIterator();
}

enum ListState
{
	// TODO: UPPER CASE
	Empty;
	Loading;
	Loaded;
}