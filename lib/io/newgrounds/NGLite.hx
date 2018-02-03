package io.newgrounds;

import io.newgrounds.components.ComponentList;
import io.newgrounds.objects.events.Result.ResultBase;
import haxe.PosInfos;
import haxe.Json;

/**
 * The barebones NG.io API. Allows API calls with code completion
 * and retrieves server data via strongly typed Objects
 * 
 * Contains many things ripped from MSGhero's repo
 *   - https://github.com/MSGhero/NG.hx
 * 
 * @author GeoKureli
 */
class NGLite {
	
	static public var core(default, null):NGLite;
	
	/** Enables verbose logging */
	public var verbose:Bool;
	public var debug:Bool;
	/** The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project. */
	public var appId(default, null):String;
	/** The name of the host the game is being played on */
	public var host:String;
	public var sessionId:String;
	
	/** Components used to call the NG server directly */
	public var calls(default, null):ComponentList;
	
	/**
	 * Converts an object to an encrypted string that can be decrypted by the server.
	 * Set your preffered encrypter here,
	 * or just call setDefaultEcryptionHandler with your app's encryption settings
	**/
	public var encryptionHandler:Dynamic->String;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component
	 * @param appId  The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param host   The name of the host the game is being played on.
	**/
	public function new(appId:String = "test") {
		
		this.appId = appId;
		
		calls = new ComponentList(this);
	}
	
	/**
	 * Creates NG.core, the heart and soul of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	static public function createCore(appId:String = "test"):Void {
		
		core = new NGLite(appId);
	}
	
	@:allow(io.newgrounds.Call)
	@:generic
	function queueCall<T:ResultBase>(call:Call<T>):Void {
		
		throw "not implemented";//TODO
	}
	
	// -------------------------------------------------------------------------------------------
	//                                   LOGGING / ERRORS
	// -------------------------------------------------------------------------------------------
	
	/** Called internally, set this to your preferred logging method */
	dynamic public function log(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		haxe.Log.trace('[Newgrounds API] :: ${any}', pos);
	}
	
	/** used internally, logs if verbose is true */
	inline public function logVerbose(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		if (verbose)
			log(any, pos);
	}
	
	/** Used internally. Logs by default, set this to your preferred error handling method */
	dynamic public function logError(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		log('Error: $any', pos);
	}
	
	/** used internally, calls log error if the condition is false. EX: if (assert(data != null, "null data")) */
	inline public function assert(condition:Bool, msg:Dynamic, ?pos:PosInfos):Bool {//TODO: limit access via @:allow
		if (!condition)
			logError(msg, pos);
		
		return condition;
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       ENCRYPTION
    // -------------------------------------------------------------------------------------------
	
	/** Sets */
	public function setDefaultEncryptionHandler
	( key   :String
	, cipher:EncryptionCipher = EncryptionCipher.AES_128
	, format:EncryptionFormat = EncryptionFormat.BASE_64
	):Void {
		
		if (cipher == EncryptionCipher.NONE)
			encryptionHandler = null;
		
		throw "not yet implemented";
		
		encryptionHandler = cipher == EncryptionCipher.AES_128
			? encryptAes128.bind(key, format)
			: encryptRc4   .bind(key, format);
	}
	
	static function encryptAes128(key:String, format:EncryptionFormat, data:Dynamic):String {
		//TODO
		return Json.stringify(data);
	}
	
	static function encryptRc4(key:String, format:EncryptionFormat, data:Dynamic):String {
		//TODO
		return Json.stringify(data);
	}
}

@:enum
abstract EncryptionCipher(Int) {
	var NONE    = 0;
	var AES_128 = 1;
	var RC4     = 2;
}

@:enum
abstract EncryptionFormat(Int) to Int{
	var BASE_64 = 64;
	var HEX     = 16;
}