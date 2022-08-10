package io.newgrounds.utils;

import io.newgrounds.NGLite;

import haxe.Http;
import haxe.PosInfos;
import haxe.Timer;

#if (target.threaded)
import sys.thread.Thread;
#elseif neko
import neko.vm.Thread;
#elseif java
import java.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

/**
 * Uses Threading to turn hxcpp's synchronous http requests into asynchronous processes
 * 
 * @author GeoKureli
 */
class AsyncNGCall {
	
	inline static var PATH:String = "https://newgrounds.io/gateway_v3.php";
	
	static public function send
	( core:NGLite
	, data:String
	, onData:String->Void
	, onError:String->Void
	, onStatus:Int->Void
	) {
		
		core.logVerbose('sending: $data');
		
		#if (target.threaded || neko || java || cpp)
		AsyncHttp.sendAsync(PATH, data, onData, onError, onStatus, core.logVerbose);
		#else
		AsyncHttp.sendSync(PATH, data, onData, onError, onStatus);
		#end
	}
}

/**
 * Uses Threading to turn hxcpp's synchronous http requests into asynchronous processes
 * 
 * @author GeoKureli
 */
@:allow(io.newgrounds.utils.AsyncNGCall)
class AsyncHttp {
	
	/** Loads a remote url */
	inline static public function getText(path, onData, onError, ?onStatus) {
		
		send(path, null, onData, onError, onStatus);
	}
	
	static public function send
	( path:String
	, data:String
	, onData:String->Void
	, onError:String->Void
	, ?onStatus:Int->Void
	) {
		
		// core.logVerbose('sending: $data');
		
		#if (target.threaded || neko || java || cpp)
		sendAsync(path, data, onData, onError, onStatus);
		#else
		sendSync(path, data, onData, onError, onStatus);
		#end
	}
	
	static function sendSync
	( path:String
	, data:String
	, onData:String->Void
	, onError:String->Void
	, ?onStatus:Int->Void
	) {
		
		var http = new Http(path);
		
		if (data != null)
			http.setParameter("input", data);
		
		http.onData   = onData;
		http.onError  = onError;
		if (onStatus != null)
			http.onStatus = onStatus;
		// #if js http.async = async; #end
		http.request(data != null);
		return http;
	}
	
	#if (target.threaded || neko || java || cpp)
	static var _map:Map<Int, AsyncHttp> = new Map();
	static var _timer:Timer;
	static var _count = 0;
	
	var _key:Int;
	var _onData:String->Void;
	var _onError:String->Void;
	var _onStatus:Null<Int->Void>;
	var _worker:Thread;
	
	public function new (?logVerbose:(String, ?PosInfos)->Void) {
		
		_key = _count++;
		_worker = Thread.create(sendThreaded);
		
		if (logVerbose != null)
			this.logVerbose = logVerbose;
		this.logVerbose('async http created: $_key');
	}
	
	function start(path:String, data:String, onData:String->Void, onError:String->Void, ?onStatus:Int->Void) {
		
		logVerbose('async http started: $_key');
		
		if (_map.keys().hasNext() == false)
			startTimer();
		
		_map[_key] = this;
		
		_onData = onData;
		_onError = onError;
		if (onStatus != null)
			_onStatus = onStatus;
		
		_worker.sendMessage({ path:path, source:Thread.current(), args:data, key:_key, logVerbose:logVerbose });
	}
	
	function handleMessage(data:ReplyData):Void {
		
		logVerbose('handling message: $_key');
		
		if (data.status != null) {
			
			logVerbose('\t- status: ${data.status}');
			if (_onStatus != null)
				_onStatus(cast data.status);
			return;
		}
		
		var tempFunc:Void->Void;
		if (data.data != null) {
			
			logVerbose('\t- data');
			tempFunc = _onData.bind(data.data);
			
		} else {
			
			logVerbose('\t- error');
			tempFunc = _onError.bind(data.error);
		}
		
		cleanUp();
		// Delay the call until destroy so that we're more likely to use a single
		// thread on daisy-chained calls
		tempFunc();
	}
	
	dynamic function logVerbose(msg:String, ?info:PosInfos) {}
	
	function cleanUp():Void {
		
		_map.remove(_key);
		
		_onData = null;
		_onError = null;
		
		if (_map.keys().hasNext() == false)
			stopTimer();
	}
	
	static function sendAsync
	( path:String
	, data:String
	, onData:(String)->Void
	, onError:(String)->Void
	, ?onStatus:(Int)->Void
	, ?logVerbose:(String, ?PosInfos)->Void
	) {
		
		var http = new AsyncHttp(logVerbose);
		http.start(path, data, onData, onError, onStatus);
	}
	
	static function startTimer():Void {
		
		if (_timer != null)
			return;
		
		_timer = new Timer(1000 / 60.0);
		_timer.run = update;
	}
	
	static function stopTimer():Void {
		
		_timer.stop();
		_timer = null;
	}
	
	static public function update():Void {
		
		var message:ReplyData = cast Thread.readMessage(false);
		if (message != null)
			_map[message.key].handleMessage(message);
	}
	
	static function sendThreaded():Void {
		
		while(true) {
			
			var data:LoaderData = cast Thread.readMessage(true);
			data.logVerbose('start message received: ${data.key}');
			
			sendSync
				( data.path
				, data.args
				, function(reply ) { data.source.sendMessage({ key:data.key, data  :reply  }); }
				, function(error ) { data.source.sendMessage({ key:data.key, error :error  }); }
				, function(status) { data.source.sendMessage({ key:data.key, status:status }); }
				);
		}
	}
	
	#end
}


#if (target.threaded || neko || java || cpp)
typedef LoaderData = { path:String, source:Thread, key:Int, args:String, logVerbose:(String)->Void };
typedef ReplyData = { key:Int, ?data:String, ?error:String, ?status:Null<Int> };
#end