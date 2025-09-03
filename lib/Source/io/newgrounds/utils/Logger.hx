package io.newgrounds.utils;

import haxe.PosInfos;

class Logger {
	
	public var log:(any:Any, ?pos:PosInfos)->Void;
	public var verbose:Bool;
	public var throwErrors:Bool;
	
	public function new (log, verbose = false, throwErrors = false) {
		
		this.log = log;
		this.verbose = verbose;
		this.throwErrors = throwErrors;
	}
	/** used internally, logs if verbose is true */
	inline public function logVerbose(any:Any, ?pos:PosInfos):Void {
		
		if (verbose)
			log(any, pos);
	}
	
	/** Used internally. Logs by default, set this to your preferred error handling method */
	public function logError(any:Any, ?pos:PosInfos):Void {
		
		if (throwErrors)
			throw '$any';
		
		log('Error: $any', pos);
	}
	
	/** used internally, calls log error if the condition is false. EX: if (assert(data != null, "null data")) */
	inline public function assert(condition:Bool, msg:Any, ?pos:PosInfos):Bool {
		if (!condition)
			logError(msg, pos);
		
		return condition;
	}
}