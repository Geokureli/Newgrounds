package io.newgrounds.test.ui;

import io.newgrounds.test.art.MedalListSwf;
import io.newgrounds.test.art.CorePageSwf;
import io.newgrounds.test.art.MedalSwf;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.Medal;
import io.newgrounds.components.Component;

import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.geom.Point;
import openfl.text.TextField;

class CorePage extends Page<Component> {
	
	inline static var DEFAULT_MEDAL_INFO:String = "Roll over a medal for more info, click to unlock.";
	
	var _login:Button;
	var _loginLabel:TextField;
	var _logout:Button;
	var _host:Input;
	var _sessionId:Input;
	
	var _loadMedals:Button;
	var _medalList:MedalListSwf;
	var _displayMedals:Map<MedalSwf, Medal>;
	
	var _loadBoards:Button;
	
	public function new (target:CorePageSwf) {
		super(null);
		
		_login = new Button(target.login, onLoginClick);
		_loginLabel = target.loginLabel;
		_loginLabel.mouseEnabled = false;
		_logout = new Button(target.logout, NG.core.logOut.bind(onLogout));
		_logout.enabled = false;
		_host = new Input(target.host, onHostChange, Input.trimEndWhitespace);
		onHostChange(_host.text);
		_sessionId = new Input(target.sessionId, onSessionIdChange);
		
		_loadMedals = new Button(target.loadMedals, loadMedals);
		_medalList = cast target.medalList;
		_medalList.visible = false;
		_medalList.info.text = DEFAULT_MEDAL_INFO;
		
		_loadBoards = new Button(target.loadBoards);//TODO
	}
	function onLoginFail(error:Error):Void {
		
		onLoginCancel();
	}
	
	function onLoginClick():Void {
		
		NG.core.requestLogin(onLogin, onLoginFail, onLoginCancel);
		
		_loginLabel.text = "cancel";
		_login.onClick = onCancelClick;
	}
	
	function onCancelClick():Void {
		
		NG.core.cancelLoginRequest();
		
		_login.enabled = false;
	}
	
	function onLoginCancel():Void {
		
		_login.enabled = true;
		_login.onClick = onLoginClick;
		_loginLabel.text = "login";
	}
	
	function onLogin():Void {
		
		_loginLabel.text = "login";
		_login.onClick = onLoginClick;
		_login.enabled = false;
		_logout.enabled = true;
		
		_sessionId.text = NG.core.sessionId;
	}
	
	function onLogout():Void {
		
		_login.enabled = true;
		_logout.enabled = false;
		
		_sessionId.text = "";
	}
	
	function onHostChange(value:String):Void {
		
		NG.core.host = value;
	}
	
	function onSessionIdChange(value:String):Void {
		
		NG.core.sessionId = value;
	}
	
	function loadMedals():Void {
		
		_medalList.visible = true;
		_medalList.loading.visible = true;
		
		NG.core.requestMedals(onMedalsLoaded);
	}
	
	function onMedalsLoaded():Void {
		
		_medalList.loading.visible = false;
		
		if (_displayMedals == null)
			createDisplayMedals();
	}
	
	inline function createDisplayMedals():Void {
		
		var i:Int = 0;
		var spacing = new Point(50, 65);
		_displayMedals = new Map<MedalSwf, Medal>();
		
		for (medalData in NG.core.medals) {
			
			var medal = new MedalSwf();
			medal.x = (i % 13) * spacing.x;
			medal.y = Math.floor(i / 13) * spacing.y;
			_medalList.addChild(medal);
			var loader = new Loader();
			loader.load(new URLRequest(medalData.icon));
			medal.icon.addChild(loader);
			
			_displayMedals.set(medal, medalData);
			
			new Button(medal, medalData.unlock().send, showMedalInfo.bind(medalData), hideMedalInfo);
			medalData.onUnlock.add(updateDisplayMedal.bind(medal));
			
			updateDisplayMedal(medal);
			
			i++;
		}
	}
	
	function updateDisplayMedals():Void {
		
		for (medal in _displayMedals.keys())
			updateDisplayMedal(medal);
	}
	
	inline function updateDisplayMedal(medal:MedalSwf):Void {
		
		var medalData = _displayMedals.get(medal);
		medal.lock.visible = !medalData.unlocked;
		medal.info.text = '${medalData.value} ${medalData.secret ? "secret" : ""}';
	}
	
	function showMedalInfo(medal:Medal):Void {
		
		_medalList.info.text = '${medal.name} - ${medal.description}';
	}
	
	function hideMedalInfo():Void {
		
		_medalList.info.text = DEFAULT_MEDAL_INFO;
	}
	
	/////////////////////////////
	
	function onBoardsLoaded():Void {
		
		
	}
}