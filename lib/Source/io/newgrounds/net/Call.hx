package io.newgrounds.net;

import haxe.Json;
import haxe.ds.StringMap;
import io.newgrounds.debug.Logger;
import io.newgrounds.net.data.AppData;
import io.newgrounds.net.data.Error;
import io.newgrounds.net.data.Response;
import io.newgrounds.net.outcomes.CallOutcome;
import io.newgrounds.net.outcomes.Outcome;
import io.newgrounds.net.results.BaseResultData;
import io.newgrounds.utils.AsyncHttp;
import io.newgrounds.utils.Dispatcher;

/** A generic way to handle calls agnostic to their type */
interface ICallable {
	
	public var component(default, null):String;
	
	public function send():Void;
	public function queue():Void;
	public function destroy():Void;
}

enum CallStatus {
	
	UNSENT;
	QUEUED;
	SENT;
	COMPLETE;
}

class Call<T:BaseResultData>
	implements ICallable {
	
	public final component:String;
	public final onSend = new Dispatcher();
	public final onQueue = new Dispatcher();
	public final onComplete = new Dispatcher();
	public var state(default, null):CallStatus = UNSENT;
	
	final _app:AppData;
	final _logger:Logger;
	final _properties = new StringMap<Any>();
	final _parameters = new StringMap<Any>();
	final _requireSession:Bool;
	final _isSecure:Bool;
	
	// --- BASICALLY SIGNALS
	final _responseHandlers = new TypedDispatcher<Response<T>>();
	final _successHandlers = new Dispatcher();
	final _httpErrorHandlers = new TypedDispatcher<String>();
	final _httpStatusHandlers = new TypedDispatcher<Int>();
	final _outcomeHandlers = new TypedDispatcher<CallOutcome<T>>();
	
	public function new (app:AppData, logger:Logger, component:String, requireSession:Bool = false, isSecure:Bool = false) {
		
		_app = app;
		_logger = logger;
		this.component = component;
		_requireSession = requireSession;
		_isSecure = isSecure;
	}
	
	/** adds a property to the input's object. **/
	public function addProperty(name:String, value:Any):Call<T> {
		
		_properties.set(name, value);
		
		return this;
	}
	
	/** adds a parameter to the call's component object. **/
	public function addComponentParameter(name:String, value:Any, ?defaultValue:Any):Call<T> {
		
		if (value == defaultValue)//TODO?: allow sending null value
			return this;
		
		_parameters.set(name, value);
		
		return this;
	}
	
	/**
	 * Handy callback setter for chained call modifiers. Unlike `addOutcomeHandler` this returns
	 * the entire server response, if one was successfuly received.
	**/
	public function addResponseHandler(handler:Response<T>->Void):Call<T> {
		
		_responseHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called whenio.newgrounds.io replies successfully */
	public function addSuccessHandler(handler:Void->Void):Call<T> {
		
		_successHandlers.add(handler);
		return this;
	}
	
	@:deprecated("addErrorHandler is deprecated, use addHttpErrorHandler")
	inline public function addErrorHandler(handler:String->Void):Call<T> {
		
		return addHttpErrorHandler(handler);
	}
	
	/** Handy callback setter for chained call modifiers. Called whenio.newgrounds.io does not reply for any reason */
	public function addHttpErrorHandler(handler:String->Void):Call<T> {
		
		_httpErrorHandlers.add(handler);
		return this;
	}
	
	@:deprecated("addStatusHandler is deprecated, use addHttpStatusHandler")
	inline public function addStatusHandler(handler:Int->Void):Call<T> {
		
		return addHttpStatusHandler(handler);
	}
	/** Handy callback setter for chained call modifiers. No idea when this is called; */
	public function addHttpStatusHandler(handler:Int->Void):Call<T> {//TODO:learn what this is for
		
		_httpStatusHandlers.add(handler);
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
		
		_outcomeHandlers.add(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called whenio.newgrounds.io does not reply for any reason */
	public function safeAddOutcomeHandler(handler:Null<(CallOutcome<T>)->Void>):Call<T> {
		
		if (handler != null)
			addOutcomeHandler(handler);
		
		return this;
	}

	/** Sends the call to the server, do not modify this object after calling this **/
	inline public function send() sendHelper(_app);
	
	
	/**
	 * Sends the call but replaces the `app_id` property with the external app id.
	 * NOTE: This is NOT meant for call like `Medal.getList`, `ScoreBoard.getScores` or
	 * `CloudSave.loadSlot`, for those use the provided `app_id` parameter. This is just a handy
	 * helper to make calls to external apps that do not require a session id, like
	 * `ScoreBoard.getBoards`.
	 * 
	 * @param   id  The id of the external app.
	 */
	inline public function sendExternalAppId(id:String) sendHelper(id == null ? _app : {id: id});
	
	function sendHelper(app:AppData):Void {
		
		_logger.assert(state.match(UNSENT | QUEUED), 'Cannot send call in unexpected state: $state');
		state = SENT;
		
		var data:Dynamic = {};
		data.app_id = app.id;
		data.call = {};
		data.call.component = component;
		
		if (app.debug)
			addProperty("debug", true);
		
		if (false == _properties.exists("session_id")) {
			// --- HAS NO SESSION ID
			
			if (app.sessionId != null) {
				// --- AUTO ADD SESSION ID
				
				addProperty("session_id", app.sessionId);
				
			} else if (_requireSession){
				
				_logger.logError('Cannot send "$component" to app: "${app.id}" call without a sessionId');
				return;
			}
		}
		
		for (field in _properties.keys())
			Reflect.setField(data, field, _properties.get(field));
		
		final params = getParameters();
		if (params != null)
			data.call.parameters = params;
		
		_logger.logVerbose('Post  - ${Json.stringify(data)}');
		
		if (_isSecure) {
			
			if (app.encryption == NONE) {
				
				_logger.logError('Cannot send "$component" to app: "${app.id}" call without encryption');
				return;
			}
			
			var secureData = app.encryption.encrypt(Json.stringify(data.call));
			data.call = {};
			data.call.secure = secureData;
			
			_logger.logVerbose('    secure - $secureData');
		}
		
		onSend.dispatch();
		
		AsyncNGCall.send(_logger, Json.stringify(data), onData, onHttpError, onHttpStatus);
		onSend.dispatch();
	}
	
	function getParameters():Null<Any> {
		
		var paramsEmpty = true;
		final params = {};
		
		for (field in _parameters.keys()) {
			
			paramsEmpty = false;
			Reflect.setField(params, field, _parameters.get(field));
		}
		
		return paramsEmpty ? null : params;
	}
	
	/** Adds the call to the queue */
	public function queue():Void {
		
		_logger.assert(state.match(UNSENT), 'Cannot queue call in unexpected state: $state');
		state = QUEUED;
		onQueue.dispatch();
	}
	
	function onData(reply:String):Void {
		
		_logger.assert(state.match(SENT), 'Unexpected state: $state');
		state = COMPLETE;
		
		_logger.logVerbose('Reply - $reply');
		
		if (_responseHandlers.isEmpty() && _successHandlers.isEmpty() && _outcomeHandlers.isEmpty())
			return;
		
		var response = new Response<T>(_logger, reply);
		
		if (response.success == false)
			_outcomeHandlers.dispatch(FAIL(RESPONSE(response.error)));
		else if (response.result.success == false)
			_outcomeHandlers.dispatch(FAIL(RESULT(response.result.error)));
		else
			_outcomeHandlers.dispatch(SUCCESS(response.result.data));
		
		_responseHandlers.dispatch(response);
		_successHandlers.dispatch();
		
		onComplete.dispatch();
		
		destroy();
	}
	
	function onHttpError(message:String):Void {
		
		state = COMPLETE;
		_logger.logError(message);
		
		_outcomeHandlers.dispatch(FAIL(HTTP(message)));
		_httpErrorHandlers.dispatch(message);
		
		onComplete.dispatch();
		
		destroy();
	}
	
	function onHttpStatus(status:Int):Void {
		
		_httpStatusHandlers.dispatch(status);
	}
	
	public function destroy():Void {
		
		onSend.clear();
		onComplete.clear();
		
		_properties.clear();
		_parameters.clear();
		
		_responseHandlers.clear();
		_successHandlers.clear();
		_httpErrorHandlers.clear();
		_httpStatusHandlers.clear();
		_outcomeHandlers.clear();
	}
}