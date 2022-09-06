package io.newgrounds.utils;

import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.ResultType;
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
	
	var _callbacks = new TypedDispatcher<ResultType>();
	
	public function new (core:NG, externalAppId:String = null) {
		
		_core = core;
		_externalAppId = externalAppId;
	}
	
	inline public function get(id:K):V return _map.get(id);
	
	function checkState(callback:Null<(ResultType)->Void>, requireLogin = false):Bool
	{
		if (requireLogin && NG.core.loggedIn == false) {
			
			if (callback != null)
				callback(Error("Must be logged in to request cloud saves"));
			
			return false;
		}
		
		switch(state) {
			
			case Loaded:
				
				if (callback != null)
					callback(Success);
				
				return false;
				
			case Empty:
				
				state = Loading;
				
				if (callback != null)
					_callbacks.add(callback);
				
				return true;
			case Loading:
				
				if (callback != null)
					_callbacks.add(callback);
				
				return false;
		}
	}
	
	function fireResponseErrors<T:ResultBase>(response:Response<T>)
	{
		if (!response.success) {
			
			fireCallbacks(Error(response.error.toString()));
			return true;
		}
		
		if (!response.result.success) {
			
			fireCallbacks(Error(response.result.error.toString()));
			return true;
		}
		
		return false;
	}
	
	function fireCallbacks(result:ResultType) {
		
		if (result.match(Error(_)))
			state = Empty;
		else
			state = Loaded;
		
		_callbacks.dispatch(result);
		
		if (result.match(Success))
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