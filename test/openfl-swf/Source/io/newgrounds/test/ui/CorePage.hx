package io.newgrounds.test.ui;

import haxe.ds.IntMap;

import flash.Lib;

import io.newgrounds.NGLite;
import io.newgrounds.components.Component;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.swf.common.Button;

import io.newgrounds.test.art.ScoreBoardListSwf;
import io.newgrounds.test.art.ScoreBoardSwf;
import io.newgrounds.test.art.ProfileSwf;
import io.newgrounds.test.art.MedalListSwf;
import io.newgrounds.test.art.CorePageSwf;
import io.newgrounds.test.art.MedalSwf;
import io.newgrounds.test.swf.ScoreBrowserSlim;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.events.IOErrorEvent;
import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.utils.Assets;

#if ng_lite
typedef CorePage = CorePageLite;
#else
class CorePage extends CorePageLite {
	
	inline static var MEDAL_INFO_LOGGED_IN:String = "Roll over a medal for more info, click to unlock.";
	inline static var MEDAL_INFO_LOGGED_OUT:String = "Roll over a medal for more info, login to enable unlocking.";
	
	var _displayMedals:Map<MedalSwf, Medal>;
	
	public function new (target:CorePageSwf) {
		super(target);
		
		initLogInOut();
		initMedals();
		initSlots();
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       LOG IN/OUT
	// -------------------------------------------------------------------------------------------
	
	inline function initLogInOut():Void {
		
		_login.onClick = onLoginClick;
		_openPassport.enabled = false;
		_profileButton.onClick = onProfileClick;
		
		NG.core.onLogin.add(onLogin);
		NG.core.onLogOut.add(onLogOut);
		
		if (NG.core.attemptingLogin) {
			
			_loginLabel.text = "CANCEL";
			_login.onClick = onCancelClick;
			
		} else if (NG.core.loggedIn)
			onLogin();
	}
	
	function onLoginPendingPassport(url:String):Void {
		
		_passportLink.text = url;
		_openPassport.enabled = true;
		_openPassport.onClick = NG.core.openPassportUrl;
	}
	
	function onLoginClick():Void {
		
		function callback(outcome:LoginOutcome) {
			
			if (outcome.match(FAIL(_)))
				onLoginFail();
		}
		
		NG.core.requestLogin(callback, onLoginPendingPassport);
		
		_loginLabel.text = "CANCEL";
		_login.onClick = onCancelClick;
	}
	
	function onCancelClick():Void {
		
		NG.core.cancelLoginRequest();
		
		_login.enabled = false;
	}
	
	function onLoginFail():Void {
		
		_login.enabled = true;
		_login.onClick = onLoginClick;
		_loginLabel.text = "LOGIN";
		_passportLink.text = "";
		_openPassport.enabled = false;
	}
	
	function onLogin():Void {
		
		_loginLabel.text = "LOGOUT";
		_login.onClick = function ():Void { NG.core.logOut(); };
		_openPassport.enabled = false;
		_passportLink.text = "";
		
		_sessionId.text = NG.core.sessionId;
		
		var user = NG.core.user;
		if (user != null){
			
			_user.text = '${user.name} (${user.id})';
			var loader:Loader = new Loader();
			loader.load(new URLRequest(user.icons.large));
			_profile.addChild(loader);
			_profile.supporter.visible = user.supporter;
			_profileButton.enabled = true;
		}
	}
	
	function onLogOut():Void {
		
		_sessionId.text = "";
		_user.text = "";
		
		_profile.supporter.visible = false;
		_profileButton.enabled = false;
		for (i in 0 ... _profile.numChildren) {
			
			if (_profile.getChildAt(i) is Loader) {
				
				_profile.removeChildAt(i);
				break;
			}
		}
	}
	
	function onProfileClick():Void {
		
		if (NG.core.user != null) {
			
			var url = NG.core.user.url;
			// --- FIX TEMP URL SERVER ISSUE
			if (url.indexOf("//") == 0)
				url = "http:" + url;
			
			Lib.getURL(new URLRequest(url));
		}
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       MEDALS
	// -------------------------------------------------------------------------------------------
	
	inline function initMedals():Void {
		
		_loadMedals.onClick = loadMedals;
		hideMedalInfo();
		NG.core.medals.onLoad.add(onMedalsLoaded);
	}
	
	function loadMedals():Void {
		
		_medalList.visible = true;
		_medalList.loading.visible = true;
		
		NG.core.requestMedals();
	}
	
	function onMedalsLoaded():Void {
		
		_medalList.visible = true;
		_medalList.loading.visible = false;
		
		if (_displayMedals == null)
			createDisplayMedals();
	}
	
	function createDisplayMedals():Void {
		
		var i:Int = 0;
		var spacing = new Point(50, 65);
		_displayMedals = new Map<MedalSwf, Medal>();
		
		for (medalData in NG.core.medals) {
			
			var medal = new MedalSwf();
			medal.x = (i % 13) * spacing.x;
			medal.y = Math.floor(i / 13) * spacing.y + 20;
			_medalList.addChild(medal);
			var loader = new Loader();
			medal.icon.addChild(loader);
			final NG_FILE = "https://img.ngfiles.com/";
			if (medalData.icon.indexOf(NG_FILE) != -1) {
				
				final path = "assets/" + medalData.icon.substring(NG_FILE.length);
				if (Assets.exists(path)) {
					
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, (e)-> {
						
						final icon = medal.icon;
						icon.removeChild(loader);
						final bitmap = new Bitmap(Assets.getBitmapData(path), true);
						bitmap.width = icon.width / icon.scaleX;
						bitmap.height = icon.height / icon.scaleY;
						icon.addChild(bitmap);
					});
				}
			}
			loader.load(new URLRequest(medalData.icon));
			
			_displayMedals.set(medal, medalData);
			
			new Button
				( medal
				, medalData.sendDebugUnlock.bind()
				, showMedalInfo.bind(medalData)
				, hideMedalInfo
				);
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
		
		_medalList.info.text = NG.core.loggedIn ? MEDAL_INFO_LOGGED_IN : MEDAL_INFO_LOGGED_OUT;
	}
	
	
	// -------------------------------------------------------------------------------------------
	//                                       Cloud Saves
	// -------------------------------------------------------------------------------------------
	
	inline function initSlots() {
		
		NG.core.saveSlots.onLoad.add(_slotsList.onSlotsLoaded);
	}
	
}
#end
	
class CorePageLite extends Page<Component> {
	
	var _login:Button;
	var _loginLabel:TextField;
	var _host:Input;
	var _sessionId:Input;
	var _user:TextField;
	var _profile:ProfileSwf;
	var _profileButton:Button;
	var _openPassport:Button;
	var _passportLink:TextField;
	
	var _loadMedals:Button;
	var _medalList:MedalListSwf;
	
	var _scoreBoardList:ScoreBoardListSwf;
	var _scoreBrowser:ScoreBrowserSlim;
	
	var _slotsList:SlotsList;
	
	public function new (target:CorePageSwf) {
		super(target);
		
		_login = new Button(target.login);
		_loginLabel = target.loginLabel;
		_loginLabel.mouseEnabled = false;
		
		_openPassport = new Button(target.openPassport);
		_passportLink = target.passportLink;
		
		_user = target.user;
		_profile = cast target.profile;
		_profile.supporter.visible = false;
		_profileButton = new Button(_profile);
		_profileButton.enabled = false;
		
		target.sessionId.text = "";
		_sessionId = new Input(target.sessionId, onSessionIdChange);
		_host = new Input(target.host, onHostChange, Input.trimEndWhitespace);
		if (NG.core.host == null)
			NG.core.host = _host.text;
		
		_loadMedals = new Button(target.loadMedals);
		_medalList = cast target.medalList;
		_medalList.visible = false;
		
		_scoreBoardList = cast target.scoreBoardList;
		_scoreBrowser = cast _scoreBoardList.scoreBrowser;
		
		_slotsList = new SlotsList(target.slotList);
		
		#if ng_lite
		_login.enabled = false;
		_openPassport.enabled = false;
		_loadMedals.enabled = false;
		_loadBoards.enabled = false;
		_user.backgroundColor = 0xCCCCCC;
		_user.text = "Note: this page is mostly deactivated because you're using ng_lite";
		#end
	}
	
	function onHostChange(value:String):Void {
		
		NG.core.host = value;
	}
	
	function onSessionIdChange(value:String):Void {
		
		NG.core.sessionId = value;
	}
}

private class SlotsList {
	
	var _target:MovieClip;
	
	public function new (slotList:MovieClip) {
		
		_target = slotList;
		_target.visible = false;
	}
	
	public function onSlotsLoaded() {
		
		_target.visible = true;
		
		var saveSlots = NG.core.saveSlots;
		var numSlots = saveSlots.length;
		
		if (numSlots == 0)
			throw 'Server returned no slots';
		
		if (numSlots > _target.numChildren)
			throw 'Save slot count exceeded expectations, slots: $numSlots, buttons: ${_target.numChildren}';
		
		for (i in 0...numSlots) {
			
			var slot = saveSlots.getOrdered(i);
			var slotMc:MovieClip = cast _target.getChildByName('slot$i');
			
			if (slotMc == null)
				throw 'missing slot$i';
			
			new Slot(slotMc, slot);
		}
		
		// remove the rest
		for (i in numSlots..._target.numChildren) {
			
			var slotMc:MovieClip = cast _target.getChildByName('slot$i');
			
			if (slotMc == null)
				throw 'missing slot$i';
			
			_target.removeChild(slotMc);
		}
	}
}

abstract Slot(MovieClip) {
	
	public function new (target:MovieClip, data:SaveSlot) {
		
		this = target;
		
		assertField("idField").text = Std.string(data.id);
		assertField("timeField").text = data.url == null ? "Empty" : data.getDate().toString();
		assertField("sizeField").text = data.prettyPrintSize();
	}
	
	@:generic
	function assertChild<T>(name:String) {
		
		var child:T = cast this.getChildByName(name);
		if (child == null)
			throw "Missing child: " + name;
		
		return child;
	}
	
	inline function assertField(name:String):TextField {
		
		return assertChild(name);
	}
}