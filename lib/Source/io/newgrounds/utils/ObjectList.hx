package io.newgrounds.utils;

import io.newgrounds.objects.Error;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;

class ObjectList<K, V> {
	
	public var state(default, null):ListState = Empty;
	
	// TODO: rename to onLoad
	/**
	 * Called after `loadList` successfully populates this list
	 */
	public var onLoaded(default, null) = new Dispatcher();
	
	var _core:NG;
	var _externalAppId:String;
	var _map:Map<K, V>;
	
	var _callbacks = new TypedDispatcher<Outcome<Error>>();
	
	public function new (core:NG, externalAppId:String = null) {
		
		_core = core;
		_externalAppId = externalAppId;
	}
	
	inline public function get(id:K):V return _map.get(id);
	
	function checkState(callback:Null<(Outcome<Error>)->Void>, allowReload = true):Bool
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
				
				if (callback != null)
					callback(SUCCESS);
				
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
	
	function fireCallbacks(outcome:Outcome<Error>) {
		
		if (outcome.match(FAIL(_)))
			state = Empty;
		else
			state = Loaded;
		
		_callbacks.dispatch(outcome);
		
		if (outcome.match(SUCCESS))
			onLoaded.dispatch();
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