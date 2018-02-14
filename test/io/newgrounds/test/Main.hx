package io.newgrounds.test;

import io.newgrounds.NG;
import io.newgrounds.NGLite.EncryptionCipher;
import io.newgrounds.NGLite.EncryptionFormat;
import io.newgrounds.components.Component;
import io.newgrounds.test.ui.RadioGroup;
import io.newgrounds.test.ui.CheckBox;
import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.MainScreen;
import io.newgrounds.test.ui.Page;
import io.newgrounds.swf.common.Button;

import openfl.display.Stage;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldType;

class Main extends Sprite {
	
	public function new() {
		super();
		
		var page = new IntroScreenSwf();
		addChild(page);
		
		new IntroPage(page, onStart.bind(page));
	}
	
	function onStart(page:IntroScreenSwf):Void {
		
		removeChild(page);
		page = null;
		
		addChild(new MainScreen());
	}
}

class IntroPage extends Page<Component> {
	
	var _onStart:Void->Void;
	
	var _appId:TextField;
	var _sessionId:TextField;
	var _start:Button;
	var _autoConnect:CheckBox;
	var _stage:Stage;
	var _encryptionKey:TextField;
	var _cipher:RadioGroup;
	var _format:RadioGroup;
	
	public function new (target:IntroScreenSwf, onStart:Void->Void):Void {
		super();
		
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
		#end
		
		_encryptionKey = target.encryptionKey;
		
		_format = new RadioGroup(target.format);
		_format.selected = EncryptionFormat.BASE_64;
		_format.disableChoice(EncryptionFormat.HEX);
		
		_cipher = new RadioGroup(target.cipher, onCipherChange);
		_cipher.selected = EncryptionCipher.RC4;
		_cipher.disableChoice(EncryptionCipher.AES_128);
		
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
		
		_format.enabled = _cipher.selected != EncryptionCipher.NONE;
	}
	
	function onStartClick():Void {
		
		#if ng_lite
		NG.create(_appId.text, _sessionId.text);
		NG.core.host = getHost(_stage);
		#else
		if (_autoConnect.on)
			NG.createAndCheckLoaderVars(_stage, _appId.text);
		else
			NG.create(_appId.text, _sessionId.text);
		#end
		if (_cipher.selected != EncryptionCipher.NONE)
			NG.core.setDefaultEncryptionHandler(_encryptionKey.text, cast _cipher.selected,cast _format.selected);
		
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