package io.newgrounds.test.ui;

import io.newgrounds.NG;
import io.newgrounds.NGLite;
import io.newgrounds.components.Component;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.swf.common.Button;
import io.newgrounds.test.art.IntroScreenSwf;

import openfl.display.Stage;
import openfl.text.TextFieldType;
import openfl.text.TextField;

typedef StartCallback = 
( appId        :String
, sessionId    :String
, debug        :Bool
, encryptionKey:String
, cipher       :Cipher
, format       :EncodingFormat
)->Void;

class IntroPage extends Page<Component> {
	
	var _onStart:StartCallback;
	
	var _appId:TextField;
	var _sessionId:TextField;
	var _start:Button;
	var _autoConnect:CheckBox;
	var _debug:CheckBox;
	var _stage:Stage;
	var _encryptionKey:TextField;
	var _cipher:RadioGroup;
	var _format:RadioGroup;
	
	public function new (target:IntroScreenSwf, onStart:StartCallback):Void {
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
		_debug.on = true;
		if (NGLite.getSessionId() != null){
			
			_autoConnect.on = true;
			onAutoConnectToggle();
		}
		#end
		
		_encryptionKey = target.encryptionKey;
		
		_format = new RadioGroup(target.format);
		_format.selected = EncodingFormat.BASE_64;
		
		_cipher = new RadioGroup(target.cipher, onCipherChange);
		_cipher.selected = Cipher.AES_128;
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
		
		_onStart
			( fieldString(_appId)
			, _autoConnect.on ? NGLite.getSessionId() : fieldString(_sessionId)
			, _debug.on
			, fieldString(_encryptionKey)
			, cast _cipher.selected
			, cast _format.selected
			);
	}
	
	#if ng_lite
	/** HELPERS
	 * copiedNG.hx's helpers which is not available in ng_lite
	 */
	inline static public function getLoaderVar(stage:Stage, name:String):String {
		
		NGLite.
	}
	#end
}