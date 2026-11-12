package io.newgrounds.lists;

import io.newgrounds.debug.Logger;
import io.newgrounds.lists.MedalList;
import io.newgrounds.lists.SaveSlotList;
import io.newgrounds.lists.ScoreBoardList;
import io.newgrounds.net.data.AppData;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.Result;
import io.newgrounds.utils.Dispatcher;

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
	
	inline public function new (core) {
		
		this = new RawExternalAppList(core);
	}
	
	@:arrayAccess
	inline public function get(appId:String) return this._map.get(appId);
}

/**
 * Note: `ExternalAppList` is just an abstract wrapper of `RawExternalAppList`, to allow array access.
 * Be sure to add any actual behavior to this class
**/
@:allow(io.newgrounds.lists.ExternalAppList)
class RawExternalAppList {
	
	final _core:BaseCore;
	final _map = new Map<String, ExternalApp>();
	
	public function new (core) {
		
		_core = core;
	}
	
	public function clear () {
		
		_map.clear();
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

class ExternalApp extends CallableCore {
	
	public var appId(get, never):String;
	inline function get_appId() return appData.id;
	
	public final saveSlots:ExternalSaveSlotList;
	public final medals:ExternalMedalList;
	public final scoreBoard:ExternalScoreBoardList;
	
	public function new (core:BaseCore, appId:String) {
		
		super
			( { id: appId, debug: core.appData.debug }
			, new Logger((any, ?pos)->core.logger.log('app[$appId] :: ${any}', pos))
			);
		
		saveSlots = new ExternalSaveSlotList(this);
		medals = new ExternalMedalList(this);
		scoreBoard = new ExternalScoreBoardList(this);
	}
}