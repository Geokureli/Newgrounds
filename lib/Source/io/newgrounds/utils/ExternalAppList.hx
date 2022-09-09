package io.newgrounds.utils;

import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;
import io.newgrounds.utils.MedalList;
import io.newgrounds.utils.SaveSlotList;
import io.newgrounds.utils.ScoreBoardList;

/**
 * A list of external apps. In the NG project manager you can give other apps access to certain
 * calls:
 * - Medal.getList
 * - ScoreBoard.getScores
 * - CloudSave.loadSlot
 * - CloudSave.loadSlots
**/
@:forward
abstract ExternalAppList (RawExternalAppList) {
	
	inline public function new (core:NG) {
		
		this = new RawExternalAppList(core);
	}
	
	@:arrayAccess
	inline public function get(appId:String) return this._map.get(appId);
}

/**
 * Note: `ExternalAppList` is just an abstract wrapper of `RawExternalAppList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:allow(io.newgrounds.utils.ExternalAppList)
class RawExternalAppList {
	
	var _core:NG;
	var _map = new Map<String, ExternalApp>();
	
	public function new (core:NG) {
		
		_core = core;
	}
	
	public function add(appId:String) {
		
		return _map[appId] = new ExternalApp(_core, appId);
	}
	
	/**
	 * Returns an Iterator over the ids of `this` list.
	 * 
	 * The order of ids is undefined.
	**/
	public inline function keys() return _map.keys();
	
	/**
	 * Returns an Iterator over the ids and values of `this` list.
	 * 
	 * The order is undefined.
	**/
	public inline function keyValueIterator() return _map.keyValueIterator();
}

class ExternalApp {
	
	public var appId(default, null):String;
	
	public var saveSlots(default, null):ExternalSaveSlotList;
	public var medals(default, null):ExternalMedalList;
	public var scoreBoard(default, null):ExternalScoreBoardList;
	
	public function new (core:NG, appId:String) {
		
		this.appId = appId;
		
		saveSlots = new ExternalSaveSlotList(core, appId);
		medals = new ExternalMedalList(core, appId);
		scoreBoard = new ExternalScoreBoardList(core, appId);
	}
}