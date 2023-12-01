package io.newgrounds;

import io.newgrounds.utils.Dispatcher;
import io.newgrounds.utils.AsyncHttp;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Outcome;

import haxe.ds.StringMap;
import haxe.Json;

/** A generic way to handle calls agnostic to their type */
interface ICallable {
	
	public var component(default, null):String;
	
	public function send():Void;
	public function queue():Void;
	public function destroy():Void;
}

class Call<T:BaseData>
	implements ICallable {
	
	public var component(default, null):String;
	
	var _core:NGLite;
	var _properties:StringMap<Dynamic>;
	var _parameters:StringMap<Dynamic>;
	var _requireSession:Bool;
	var _isSecure:Bool;
	
	// --- BASICALLY SIGNALS
	var _responseHandlers:TypedDispatcher<Response<T>>;
	var _successHandlers:Dispatcher;
	var _httpErrorHandlers:TypedDispatcher<Error>;
	var _statusHandlers:TypedDispatcher<Int>;
	var _outcomeHandlers:TypedDispatcher<CallOutcome<T>>;
	
	public function new (core:NGLite, component:String, requireSession:Bool = false, isSecure:Bool = false) {
		
		_core = core;
		this.component = component;
		_requireSession = requireSession;
		_isSecure = isSecure && core.encryptionHandler != null;
	}
	
	/** adds a property to the input's object. **/
	public function addProperty(name:String, value:Dynamic):Call<T> {
		
		if (_properties == null)
			_properties = new StringMap<Dynamic>();
		
		_properties.set(name, value);
		
		return this;
	}
	
	/** adds a parameter to the call's component object. **/
	public function addComponentParameter(name:String, value:Dynamic, defaultValue:Dynamic = null):Call<T> {
		
		if (value == defaultValue)//TODO?: allow sending null value
			return this;
		
		if (_parameters == null)
			_parameters = new StringMap<Dynamic>();
		
		_parameters.set(name, value);
		
		return this;
	}
	
	/**
	 * Handy callback setter for chained call modifiers. Unlike `addOutcomeHandler` this returns
	 * the entire server response, if one was successfuly received.
	**/
	public function addResponseHandler(handler:Response<T>->Void):Call<T> {
		
		if (_responseHandlers == null)
			_responseHandlers = new TypedDispatcher<Response<T>>();
		
		_responseHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io replies successfully */
	public function addSuccessHandler(handler:Void->Void):Call<T> {
		
		if (_successHandlers == null)
			_successHandlers = new Dispatcher();
		
		_successHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io does not reply for any reason */
	public function addErrorHandler(handler:Error->Void):Call<T> {
		
		if (_httpErrorHandlers == null)
			_httpErrorHandlers = new TypedDispatcher<Error>();
		
		_httpErrorHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. No idea when this is called; */
	public function addStatusHandler(handler:Int->Void):Call<T> {//TODO:learn what this is for
		
		if (_statusHandlers == null)
			_statusHandlers = new TypedDispatcher<Int>();
		
		_statusHandlers.add(handler);
		return this;
	}
	
	/**
	 * Handy callback setter for chained call modifiers. This callback is always called with
	 * The following Values:
	 * - `SUCCESS(data:T)` - The server responded with no errors, `data` is `response.result.data`.
	 * - `FAIL(HTTP(error:String))` - There was an error sending the request or receiving the result.
	 * - `FAIL(RESPONSE(error:Error))` - There was an error understanding the call.
	 * - `FAIL(RESULT(error:Error))` - There was an error executing the call.
	**/
	public function addOutcomeHandler(handler:(CallOutcome<T>)->Void):Call<T> {
		
		if (_outcomeHandlers == null)
			_outcomeHandlers = new TypedDispatcher<CallOutcome<T>>();
		
		_outcomeHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io does not reply for any reason */
	public function safeAddOutcomeHandler(handler:Null<(CallOutcome<T>)->Void>):Call<T> {
		
		if (handler != null)
			addOutcomeHandler(handler);
		
		return this;
	}

	/** Sends the call to the server, do not modify this object after calling this **/
	inline public function send() sendHelper();
	
	/**
	 * Sends the call but replaces the `app_id` property with the external app id.
	 * NOTE: This is NOT meant for call like `Medal.getList`, `ScoreBoard.getScores` or
	 * `CloudSave.loadSlot`, for those use the provided `app_id` parameter. This is just a handy
	 * helper to make calls to external apps that do not require a session id, like
	 * `ScoreBoard.getBoards`.
	 * 
	 * @param   id  The id of the external app.
	 */
	inline public function sendExternalAppId(id:String) sendHelper(id);
	
	function sendHelper(?externalAppId:String):Void {
		
		final isExternal = externalAppId != null;
		
		var data:Dynamic = {};
		data.app_id = isExternal ? externalAppId : _core.appId;
		data.call = {};
		data.call.component  = component;
		
		if (_core.debug)
			addProperty("debug", true);
		
		if (_properties == null || !_properties.exists("session_id")) {
			// --- HAS NO SESSION ID
			
			if (_core.sessionId != null && isExternal == false) {
				// --- AUTO ADD SESSION ID
				
				addProperty("session_id", _core.sessionId);
				
			} else if (_requireSession){
				
				if (isExternal)
					_core.logError(new Error('cannot send "$component" call to an external app'));
				else
					_core.logError(new Error('cannot send "$component" call without a sessionId'));
				
				return;
			}
		}
		
		if (_properties != null) {
			
			for (field in _properties.keys())
				Reflect.setField(data, field, _properties.get(field));
		}
		
		if (_parameters != null) {
			
			data.call.parameters = {};
			
			for (field in _parameters.keys())
				Reflect.setField(data.call.parameters, field, _parameters.get(field));
		}
		
		_core.logVerbose('Post  - ${Json.stringify(data)}');
		
		if (_isSecure) {
			
			if (isExternal) {
				
				_core.logError(new Error('cannot send "$component" call to an external app that requires encryption'));
				return;
			}
			
			var secureData = _core.encryptionHandler(Json.stringify(data.call));
			data.call = {};
			data.call.secure = secureData;
			
			_core.logVerbose('    secure - $secureData');
		}
		
		_core.markCallPending(this);
		
		AsyncNGCall.send(_core, Json.stringify(data), onData, onHttpError, onStatus);
	}
	
	/** Adds the call to the queue */
	public function queue():Void {
		
		_core.queueCall(this);
	}
	
	function onData(reply:String):Void {
		
		_core.logVerbose('Reply - $reply');
		
		if (_responseHandlers == null && _successHandlers == null && _outcomeHandlers == null)
			return;
		
		var response = new Response<T>(_core, reply);
		
		if (_outcomeHandlers != null)
		{
			if (response.success == false)
				_outcomeHandlers.dispatch(FAIL(RESPONSE(response.error)));
			else if (response.result.success == false)
				_outcomeHandlers.dispatch(FAIL(RESULT(response.result.error)));
			else
				_outcomeHandlers.dispatch(SUCCESS(response.result.data));
		}
		
		if (_responseHandlers != null)
			_responseHandlers.dispatch(response);
		
		if (response.success && response.result.success && _successHandlers != null)
			_successHandlers.dispatch();
		
		destroy();
	}
	
	function onHttpError(message:String):Void {
		
		_core.logError(message);
		
		if (_outcomeHandlers != null)
			_outcomeHandlers.dispatch(FAIL(HTTP(message)));
		
		if (_httpErrorHandlers != null)
			_httpErrorHandlers.dispatch(new Error(message));
	}
	
	function onStatus(status:Int):Void {
		
		if (_statusHandlers == null)
			return;
		
		_statusHandlers.dispatch(status);
	}
	
	public function destroy():Void {
		
		_core = null;
		
		_properties = null;
		_parameters = null;
		
		_responseHandlers = null;
		_successHandlers = null;
		_httpErrorHandlers = null;
		_statusHandlers = null;
		_outcomeHandlers = null;
	}
}

typedef CallOutcome<T> = TypedOutcome<T, CallError>;

@:using(io.newgrounds.Call.CallErrorTools)
enum CallError
{
	/** There was an error sending the request or receiving the result. */
	HTTP(error:String);
	
	/** There was an error understanding the call. */
	RESPONSE(error:Error);
	
	/** There was an error executing the call. */
	RESULT(error:Error);
}

class CallErrorTools
{
	static public function toString(error:CallError)
	{
		return switch (error)
		{
			case HTTP(e): 'Http Error: $e';
			case RESPONSE(e): 'Response Error: $e';
			case RESULT(e): 'Result Error: $e';
		}
	}
}