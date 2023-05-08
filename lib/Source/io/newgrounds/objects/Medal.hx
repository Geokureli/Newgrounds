package io.newgrounds.objects;

import io.newgrounds.Call;
import io.newgrounds.NGLite;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result;
import io.newgrounds.utils.Dispatcher;

typedef RawMedalData =
{
	id         :Int,
	name       :String,
	description:String,
	icon       :String,
	value      :Int,
	difficulty :Difficulty,
	secret     :Int,
	unlocked   :Bool
}

class Medal extends Object<RawMedalData> {
	
	inline static public var EASY        = Difficulty.EASY;
	inline static public var MODERATE    = Difficulty.MODERATE;
	inline static public var CHALLENGING = Difficulty.CHALLENGING;
	inline static public var DIFFICULT   = Difficulty.DIFFICULT;
	inline static public var BRUTAL      = Difficulty.BRUTAL;
	
	// --- FROM SERVER
	public var id         (get, never):Int   ; inline function get_id         () return _data.id;
	public var name       (get, never):String; inline function get_name       () return _data.name;
	public var description(get, never):String; inline function get_description() return _data.description;
	public var icon       (get, never):String; inline function get_icon       () return _data.icon;
	public var value      (get, never):Int   ; inline function get_value      () return _data.value;
	public var difficulty (get, never):Int   ; inline function get_difficulty () return _data.difficulty;
	public var secret     (get, never):Bool  ; inline function get_secret     () return _data.secret == 1;
	public var unlocked   (get, never):Bool  ; inline function get_unlocked   () return _data.unlocked;
	// --- HELPERS
	public var difficultyName(get, never):String;
	
	public var onUnlock:Dispatcher;
	
	public function new(core:NGLite, data:RawMedalData = null):Void {
		
		onUnlock = new Dispatcher();
		
		super(core, data);
	}

	@:allow(io.newgrounds.NG)
	override function parse(data:RawMedalData):Void {
		
		var wasLocked = _data == null || !unlocked;
		
		super.parse(data);
		
		if (wasLocked && unlocked)
			onUnlock.dispatch();
	}
	
	public function sendUnlock(?callback:(Outcome<CallError>)->Void):Void {
		
		if (_core.sessionId == null) {
			// --- Unlock regardless, show medal popup to encourage NG signup
			_data.unlocked = true;
			onUnlock.dispatch();
			//TODO: save unlock in local save
		}
		
		_core.calls.medal.unlock(id)
			.addOutcomeHandler(onUnlockResponse.bind(_, callback))
			.send();
	}
	
	function onUnlockResponse(outcome:CallOutcome<MedalUnlockData>, callback:Null<(Outcome<CallError>)->Void>):Void {
		
		switch (outcome)
		{
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
			{
				parse(data.medal);
				
				// --- Unlock response doesn't include unlock=true, so parse won't change it.
				if (!unlocked) {
					
					_data.unlocked = true;
					callback.safe(outcome.toUntyped());
					onUnlock.dispatch();
				}
			}
		}
	}
	
	/** Locks the medal on the client and sends an unlock request, Server responds the same either way. */ 
	public function sendDebugUnlock(?callback:Null<(Outcome<CallError>)->Void>):Void {
		
		if (NG.core.sessionId == null) {
			
			callback.safe(SUCCESS);
			onUnlock.dispatch();
			
		} else {
			
			_data.unlocked = false;
			
			sendUnlock(callback);
		}
	}
	
	inline public function get_difficultyName():String {
		
		return switch(difficulty)
		{
			case Difficulty.EASY       : "Easy";
			case Difficulty.MODERATE   : "Moderate";
			case Difficulty.CHALLENGING: "Challenging";
			case Difficulty.DIFFICULT  : "Difficult";
			case Difficulty.BRUTAL     : "Brutal";
			case _:
				throw 'invalid difficulty: $difficulty';
		}
	}
	
	public function toString():String {
		
		return 'Medal: $id@$name (${unlocked ? "unlocked" : "locked"}, $value pts, $difficultyName).';
	}
}

#if haxe4 enum #else @:enum #end
abstract Difficulty(Int) from Int to Int {
	
	var EASY        = 1;
	var MODERATE    = 2;
	var CHALLENGING = 3;
	var DIFFICULT   = 4;
	var BRUTAL      = 5;
}