package io.newgrounds.lists;

import io.newgrounds.net.Call;
import io.newgrounds.net.data.AppData;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.Result;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.utils.Dispatcher;

class ObjectList<K, V> {
	
	public var state(default, null):ListState = Empty;
	
	/**
	 * Called after `loadList` successfully populates this list, for the first time.
	 */
	public var onLoad(default, null) = new Dispatcher();
	
	final _core:CallableCore;
	var _map:Map<K, V>;
	
	var _callbacks = new TypedDispatcher<Outcome<CallError>>();
	
	public function new (core:CallableCore) {
		
		_core = core;
	}
	
	inline public function get(id:K):V return _map.get(id);
	
	function checkState(callback:Null<(Outcome<CallError>)->Void>, allowReload = true):Bool
	{
		inline function addCallback()
		{
			if (callback != null)
				_callbacks.addOnce(callback);
		}
		
		switch(state) {
			
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
	
	function fireCallbacks(outcome:Outcome<CallError>) {
		
		var firstFire = state != Loaded;
		
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

enum ListState {
	
	// TODO: UPPER CASE
	Empty;
	Loading;
	Loaded;
}