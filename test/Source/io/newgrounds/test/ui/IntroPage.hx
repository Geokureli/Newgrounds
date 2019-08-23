package io.newgrounds.test.ui;

import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.components.Component;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncryptionFormat;
import io.newgrounds.swf.common.Button;

import openfl.display.Stage;
import openfl.text.TextFieldType;
import openfl.text.TextField;

class IntroPage extends Page<Component> {
	
	var _onStart:Void->Void;
	
	var _appId:TextField;
	var _sessionId:TextField;
	var _start:Button;
	var _autoConnect:CheckBox;
	var _debug:CheckBox;
	var _stage:Stage;
	var _encryptionKey:TextField;
	var _cipher:RadioGroup;
	var _format:RadioGroup;
	
	public function new (target:IntroScreenSwf, onStart:Void->Void):Void {
		super(target);
		
		_stage = target.stage;
		
		_onStart = onStart;
		
		_appId = target.appId;
		_sessionId = target.sessionId;
		_start = new Button(target.start, onStartClick);
		
		#if ng_lite
		target.autoConnect.gotoAndStop("disabled");
		target.autoConnect.getChildByName("check").visible = false;
		//TODO: fix _autoConnect.enabled = false;
		
		var autoSession:String = getLoaderVar(_stage, "ngio_session_id");
		if (autoSession != null)
			_sessionId.text = autoSession;
		#else
		_autoConnect = new CheckBox(target.autoConnect, onAutoConnectToggle);
		_debug = new CheckBox(target.debug);
		if (NGLite.getSessionId() != null){
			
			_autoConnect.on = true;
			onAutoConnectToggle();
		}
		#end
		
		_encryptionKey = target.encryptionKey;
		
		_format = new RadioGroup(target.format);
		_format.selected = EncryptionFormat.BASE_64;
		_format.disableChoice(EncryptionFormat.HEX);
		
		_cipher = new RadioGroup(target.cipher, onCipherChange);
		_cipher.selected = Cipher.RC4;
		_cipher.disableChoice(Cipher.AES_128);
		
	}
	
	function onAutoConnectToggle():Void {
		
		if (_autoConnect.on) {
			
			_sessionId.type = TextFieldType.DYNAMIC;
			_sessionId.selectable = false;
			_sessionId.backgroundColor = 0xE8E8E8;
			_sessionId.textColor = 0x666666;
		
		} else {
			
			_sessionId.type = TextFieldType.INPUT;
			_sessionId.selectable = true;
			_sessionId.backgroundColor = 0xFFFFFF;
			_sessionId.textColor = 0x000000;
		}
	}
	
	function onCipherChange():Void {
		
		_format.enabled = _cipher.selected != Cipher.NONE;
	}
	
	function onStartClick():Void {
		
		#if ng_lite
		NG.create(fieldString(_appId), fieldString(_sessionId), _debug.on);
		NG.core.host = getHost(_stage);
		#else
		if (_autoConnect.on)
			NG.createAndCheckSession(fieldString(_appId), _debug.on);
		else
			NG.create(fieldString(_appId), fieldString(_sessionId), _debug.on);
		#end
		if (_cipher.selected != Cipher.NONE)
			NG.core.initEncryption(fieldString(_encryptionKey), cast _cipher.selected, cast _format.selected);
		
		NG.core.verbose = true;
		
		_onStart();
	}
	
	#if ng_lite
	/** HELPERS
	 * copiedNG.hx's helpers which is not available in ng_lite
	 */
	inline static public function getLoaderVar(stage:Stage, name:String):String {
		
		if (Reflect.hasField(stage.loaderInfo.parameters, name))
			return Reflect.field(stage.loaderInfo.parameters, name);
		
		return null;
	}
	
	
	static var urlParser:EReg = ~/^(?:http[s]?:\/\/)?([^:\/\s]+)(:[0-9]+)?((?:\/\w+)*\/)([\w\-\.]+[^#?\s]+)([^#\s]*)?(#[\w\-]+)?$/i;//TODO:trim
	/** Used to get the current web host of your game. */
	static public function getHost(stage:Stage):String {
		
		var url = stage.loaderInfo.url;
		
		if (url == null || url == "")
			return "<AppView>";
		
		if (url.indexOf("file") == 0)
			return "<LocalHost>";
		
		if (urlParser.match(url))
			return urlParser.matched(1);
		
		return "<Unknown>";
	}
	#end
}