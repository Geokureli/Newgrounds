package io.newgrounds.test.ui;

import io.newgrounds.test.swf.ScoreBrowserSlim;
import haxe.ds.IntMap;

import flash.Lib;

import io.newgrounds.test.art.ScoreBoardListSwf;
import io.newgrounds.test.art.ScoreBoardSwf;
import io.newgrounds.test.art.ProfileSwf;
import io.newgrounds.test.art.MedalListSwf;
import io.newgrounds.test.art.CorePageSwf;
import io.newgrounds.test.art.MedalSwf;

import io.newgrounds.swf.common.Button;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.components.Component;

import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.geom.Point;
import openfl.text.TextField;

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
		initBoards();
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
	
	function onLoginFail(error:Error):Void {
		
		onLoginCancel();
	}
	
	function onLoginPendingPassport():Void {
		
		_passportLink.text = NG.core.passportUrl;
		_openPassport.enabled = true;
		_openPassport.onClick = NG.core.openPassportUrl;
	}
	
	function onLoginClick():Void {
		
		NG.core.requestLogin
			( null
			, onLoginPendingPassport
			, onLoginFail
			, onLoginCancel
			);
		
		_loginLabel.text = "CANCEL";
		_login.onClick = onCancelClick;
	}
	
	function onCancelClick():Void {
		
		NG.core.cancelLoginRequest();
		
		_login.enabled = false;
	}
	
	function onLoginCancel():Void {
		
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
			
			if (Std.is(_profile.getChildAt(i), Loader)) {
				
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
		NG.core.onMedalsLoaded.add(onMedalsLoaded);
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
			
			new Button
				( medal
				, medalData.sendDebugUnlock
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
	//                                       SCOREBOARDS
	// -------------------------------------------------------------------------------------------
	
	var _boardPages:IntMap<Int>;
	
	inline function initBoards():Void {
		
		_loadBoards.onClick = loadBoards;
		NG.core.onScoreBoardsLoaded.add(onBoardsLoaded);
		_scoreBrowser.boardId = -1;
	}
	
	function loadBoards():Void {
		
		NG.core.requestScoreBoards();
	}
	
	function onBoardsLoaded():Void {
		
		_loadBoards.enabled = false;
		_scoreBoardList.visible = true;
		
		var i:Int = 0;
		var spacing = 22;
		_displayBoards = new Map<ScoreBoardSwf, ScoreBoard>();
		_boardPages = new IntMap<Int>();
		
		for (boardData in NG.core.scoreBoards) {
			
			var board = new ScoreBoardSwf();
			board.y = i * spacing;
			board.id.text = Std.string(boardData.id);
			board.boardName.text = boardData.name;
			_scoreBoardList.addChild(board);
			
			_displayBoards.set(board, boardData);
			_boardPages.set(boardData.id, -1);
			
			new Button(board, getScores.bind(boardData));
			
			i++;
			if (i == 10)
				break;
		}
	}
	
	function getScores(board:ScoreBoard = null):Void {
		
		var page:Int = _boardPages.get(board.id);
		if (page == -1)
			page = 0;
		
		_scoreBrowser.boardId = board.id;
		_scoreBrowser.page = page;
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
	
	var _loadBoards:Button;
	var _scoreBoardList:ScoreBoardListSwf;
	var _displayBoards:Map<ScoreBoardSwf, ScoreBoard>;
	var _scoreBrowser:ScoreBrowserSlim;
	
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
		
		_loadBoards = new Button(target.loadBoards);
		_scoreBoardList = cast target.scoreBoardList;
		_scoreBoardList.visible = false;
		_scoreBrowser = cast _scoreBoardList.scoreBrowser;
		_scoreBrowser.boardId = -1;
		
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