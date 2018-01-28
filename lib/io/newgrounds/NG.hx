package io.newgrounds;

import io.newgrounds.components.GatewayComponent;
import io.newgrounds.components.LoaderComponent;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.components.EventComponent;
import io.newgrounds.components.AppComponent;
import io.newgrounds.components.MedalComponent;
import haxe.PosInfos;
import haxe.Json;
import haxe.Log;

/**
 * The Newgrounds API for Haxe.
 * Contains many things ripped from MSGhero
 *   - https://github.com/MSGhero/NG.hx
 * @author GeoKureli
 */
class NG {
	
	static public var core(default, null):NG;
	
	/** Enables verbose logging */
	public var verbose:Bool;
	/** The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project. */
	public var appId(default, null):String;
	/** A unique session id used to identify the active user. */
	public var sessionId(get, never):String;
	/**
	 * Converts an object to an encrypted string that can be decrypted by the server.
	 * Set your preffered encrypter here,
	 * or just call setDefaultEcryptionHandler with your app's encryption settings
	**/
	public var encryptionHandler:Dynamic->String;
	
	// --- COMPONENTS
	public var medal     : MedalComponent;
	public var app       : AppComponent;
	public var event     : EventComponent;
	public var scoreBoard: ScoreBoardComponent;
	public var loader    : LoaderComponent;
	public var gateway   : GatewayComponent;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component
	 * @param appId     The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 * @param sessionId A unique session id used to identify the active user.
	**/
	public function new(appId:String = "test") {
		
		this.appId = appId;
		
		medal = new MedalComponent(this);
		app = new AppComponent(this);
		event = new EventComponent(this);
		scoreBoard = new ScoreBoardComponent(this);
		loader = new LoaderComponent(this);
		gateway = new GatewayComponent(this);
	}
	
	/** Called internally, set this to your preferred logging method */
	dynamic public function log(any:Dynamic, ?pos:PosInfos):Void {//TODO: limit access via @:allow
		
		haxe.Log.trace('[Newgrounds API] :: ${any}', pos);
		
		// ExternalInterface call to the NG Project Preview Debug Window
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
	
	public function queueCall(call:Call):Void {
		
		throw "not implemented";
	}
	
	/**
	 * Creates NG.core, the heart and sould of the API. This is not the only way to create an instance,
	 * nor is NG a forced singleton, but it's the only way to set the static NG.core.
	**/
	static public function createCore(appId:String = "test"):Void {
		
		core = new NG(appId);
	}
	
	public function get_sessionId():String {
		
		return app.sessionId;
	}
	
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