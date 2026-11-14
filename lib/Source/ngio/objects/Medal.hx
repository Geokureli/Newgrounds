package ngio.objects;

import ngio.data.MedalData;
import ngio.events.Dispatcher;
import ngio.net.Call;
import ngio.net.CallOutcome;
import ngio.net.Outcome;
import ngio.net.Response;
import ngio.net.results.Result;
import ngio.net.results.medal.*;
import ngio.objects.Object;

using ngio.net.Outcome.OutcomeTools;
using ngio.net.Outcome.TypedOutcomeTools;

class Medal extends Object<MedalData>
{
	@:depracated("Medal.EASY is deprecated, use Difficulty.EASY, instead")
	inline static public var EASY        = ngio.data.MedalData.Difficulty.EASY;
	@:depracated("Medal.MODERATE is deprecated, use Difficulty.MODERATE, instead")
	inline static public var MODERATE    = ngio.data.MedalData.Difficulty.MODERATE;
	@:depracated("Medal.CHALLENGING is deprecated, use Difficulty.CHALLENGING, instead")
	inline static public var CHALLENGING = ngio.data.MedalData.Difficulty.CHALLENGING;
	@:depracated("Medal.DIFFICULT is deprecated, use Difficulty.DIFFICULT, instead")
	inline static public var DIFFICULT   = ngio.data.MedalData.Difficulty.DIFFICULT;
	@:depracated("Medal.BRUTAL is deprecated, use Difficulty.BRUTAL, instead")
	inline static public var BRUTAL      = ngio.data.MedalData.Difficulty.BRUTAL;
	
	// --- FROM SERVER
	public var id         (get, never):Int       ; inline function get_id         () return _data.id;
	public var name       (get, never):String    ; inline function get_name       () return _data.name;
	public var description(get, never):String    ; inline function get_description() return _data.description;
	public var icon       (get, never):String    ; inline function get_icon       () return _data.icon;
	public var value      (get, never):Int       ; inline function get_value      () return _data.value;
	public var difficulty (get, never):Difficulty; inline function get_difficulty () return _data.difficulty;
	public var secret     (get, never):Bool      ; inline function get_secret     () return _data.secret;
	public var unlocked   (get, never):Bool      ; inline function get_unlocked   () return _data.unlocked;
	// --- HELPERS
	public var difficultyName(get, never):String;
	inline public function get_difficultyName() return difficulty.toString();
	
	public final onUnlock = new Dispatcher();
	
	final onUnlockCalled = new TypedDispatcher<(CallOutcome<MedalUnlockResultData>)->Void>();

	override function parse(data:MedalData):Void
	{
		final wasLocked = _data == null || !unlocked;
		
		super.parse(data);
		
		if (wasLocked && unlocked)
			onUnlock.dispatch();
	}
	
	public function sendUnlock(?callback:(Outcome<CallError>)->Void, force = false)
	{
		if (unlocked && !force)
		{
			callback.safe(SUCCESS);
			return;
		}
		
		onUnlockCalled.dispatch(onUnlockResponse.bind(_, callback));
	}
	
	function onUnlockResponse(outcome:CallOutcome<MedalUnlockResultData>, callback:Null<(Outcome<CallError>)->Void>)
	{
		switch (outcome)
		{
			case FAIL(error): callback.safe(FAIL(error));
			case SUCCESS(data):
			{
				parse(data.medal);
				
				callback.safe(outcome.toUntyped());
			}
		}
	}
	
	/** Locks the medal on the client and sends an unlock request, Server responds the same either way. */ 
	@:deprecated("sendDebugUnlock is deprecated, there is no replacement")
	public function sendDebugUnlock(?callback:Null<(Outcome<CallError>)->Void>):Void {
		
		if (NG.core.appData.sessionId == null) {
			
			callback.safe(SUCCESS);
			onUnlock.dispatch();
			
		} else {
			
			_data.unlocked = false;
			
			sendUnlock(callback);
		}
	}
	
	public function toString():String
	{
		return 'Medal: $id@$name (${unlocked ? "unlocked" : "locked"}, $value pts, $difficultyName).';
	}
}