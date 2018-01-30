package io.newgrounds;

import io.newgrounds.objects.Error;
import haxe.ds.StringMap;
import haxe.Json;
import haxe.Http;

class Call {
	
	inline static var PATH:String = "https://newgrounds.io/gateway_v3.php";
	
	var _core:NGLite;
	
	var _component:String;
	var _properties:StringMap<Dynamic>;
	var _parameters:StringMap<Dynamic>;
	var _requireSession:Bool;
	var _isSecure:Bool;
	
	// --- BASICALLY SIGNALS
	var _dataHandlers:Array<Dynamic->Void>;
	var _successHandlers:Array<Void->Void>;
	var _httpErrorHandlers:Array<String->Void>;
	var _statusHandlers:Array<Int->Void>;
	
	public function new (core:NGLite, component:String, requireSession:Bool = false, isSecure:Bool = false) {
		
		_core = core;
		_component = component;
		_requireSession = requireSession;
		_isSecure = isSecure && core.encryptionHandler != null;
	}
	
	/** adds a property to the input's object. **/
	public function addProperty(name:String, value:Dynamic):Call {
		
		if (_properties == null)
			_properties = new StringMap<Dynamic>();
		
		_properties.set(name, value);
		
		return this;
	}
	
	/** adds a parameter to the call's component object. **/
	public function addComponentParameter(name:String, value:Dynamic, defaultValue:Dynamic = null):Call {
		
		if (value == defaultValue)//TODO allow sending null value
			return this;
		
		if (_parameters == null)
			_parameters = new StringMap<Dynamic>();
		
		_parameters.set(name, value);
		
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io replies successfully */
	public function addDataHandler(handler:Dynamic->Void):Call {
		
		if (_dataHandlers == null)
			_dataHandlers = new Array<Dynamic->Void>();
		
		_dataHandlers.push(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io replies successfully */
	public function addSuccessHandler(handler:Void->Void):Call {
		
		if (_successHandlers == null)
			_successHandlers = new Array<Void->Void>();
		
		_successHandlers.push(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. Called when ng.io does not reply for any reason */
	public function addErrorHandler(handler:String->Void):Call {
		
		if (_httpErrorHandlers == null)
			_httpErrorHandlers = new Array<String->Void>();
		
		_httpErrorHandlers.push(handler);
		return this;
	}
	
	/** Handy callback setter for chained call modifiers. No idea when this is called; */
	public function addStatusHandler(handler:Int->Void):Call {//TODO:learn what this is for
		
		if (_statusHandlers == null)
			_statusHandlers = new Array<Int->Void>();
		
		_statusHandlers.push(handler);
		return this;
	}

	/** 
	 * Sends the call to the server, do not modify this object after calling this
	 * @param secure    If encryption is enabled, it will encrypt the call.
	**/
	public function send():Void {
		
		var data:Dynamic = {};
		data.app_id = _core.appId;
		data.call = {};
		data.call.component  = _component;
		
		if (_requireSession && !_properties.exists("session_id")) {
			
			if (_core.assert(Std.is(_core, NG) && cast (_core, NG).sessionId != null, 'cannot send "$_component" call without a sessionId'))
				addProperty("session_id", cast(_core, NG).sessionId);
			else
				return;
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
			
			var secureData = _core.encryptionHandler(data.call);
			data.call = {};
			data.call.secure = secureData;
			
			_core.logVerbose('    secure - $secureData');
		}
		
		var http = new Http(PATH);
		http.setParameter("input", Json.stringify(data));
		http.onData   = onData;
		http.onError  = onHttpError;
		http.onStatus = onStatus;
		http.request(true);
	}
	
	/** Adds the call to the queue */
	public function queue():Void {
		
		_core.queueCall(this);
	}
	
	function onData(reply:String):Void {
		
		_core.logVerbose('Reply - $reply');
		
		if (_dataHandlers == null && _successHandlers == null)
			return;
		
		var data = Json.parse(reply);
		
		if (!data.success) {
			
			_core.logError('Call unseccessful, error: ${data.error}');
			onHttpError(Json.stringify(data.error));
			return;
		}
		
		if (_dataHandlers != null) {
			
			for (callback in _dataHandlers)
				callback(data.result);
		}
		
		if (data.result.data.success && _successHandlers != null) {
			
			for (callback in _successHandlers)
				callback();
		}
		
		destroy();
	}
	
	function onHttpError(msg:String):Void {
		
		_core.logError(msg);
		
		if (_httpErrorHandlers == null)
			return;
		
		for (callback in _httpErrorHandlers)
			callback(msg);
	}
	
	//function onError()
	
	function onStatus(status:Int):Void {
		
		if (_statusHandlers == null)
			return;
		
		for (callback in _statusHandlers)
			callback(status);
	}
	
	public function destroy():Void {
		
		_core = null;
		
		_properties = null;
		_parameters = null;
		
		_dataHandlers = null;
		_successHandlers = null;
		_httpErrorHandlers = null;
		_statusHandlers = null;
	}
}
