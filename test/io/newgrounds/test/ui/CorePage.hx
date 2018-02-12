package io.newgrounds.test.ui;

import haxe.ds.IntMap;

import flash.Lib;

import io.newgrounds.test.art.ScoreBoardListSwf;
import io.newgrounds.test.art.ScoreBoardSwf;
import io.newgrounds.test.art.ProfileSwf;
import io.newgrounds.test.art.MedalListSwf;
import io.newgrounds.test.art.CorePageSwf;
import io.newgrounds.test.art.MedalSwf;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.components.Component;
import io.newgrounds.components.ScoreBoardComponent.Period;

import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.geom.Point;
import openfl.text.TextField;

#if ng_lite
typedef CorePage = CorePageLite;
#else
class CorePage extends CorePageLite {
	
	inline static var DEFAULT_MEDAL_INFO:String = "Roll over a medal for more info, click to unlock.";
	
	var _boardPages:IntMap<Int>;
	var _currentBoard:Int;
	
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
		_logout.onClick = function() { NG.core.logOut(); };
		_profileButton.onClick = onProfileClick;
		
		NG.core.onLogin.add(onLogin);
		NG.core.onLogOut.add(onLogOut);
		
		if (NG.core.attemptingLogin) {
			
			_loginLabel.text = "cancel";
			_login.onClick = onCancelClick;
		}
	}
	
	function onLoginFail(error:Error):Void {
		
		onLoginCancel();
	}
	
	function onLoginClick():Void {
		
		NG.core.requestLogin(onLoginFail, onLoginCancel);
		
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
		
		_login.enabled = true;
		_logout.enabled = false;
		
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
		_medalList.info.text = DEFAULT_MEDAL_INFO;
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
		
		_medalList.info.text = DEFAULT_MEDAL_INFO;
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       SCOREBOARDS
	// -------------------------------------------------------------------------------------------
	
	var _boardInfo:TextField;
	var _prev:Button;
	var _next:Button;
	var _refresh:Button;
	var _tag:TextField;
	var _social:CheckBox;
	var _period:DropDown;
	
	inline function initBoards():Void {
		
		_boardInfo = _scoreBoardList.info;
		_boardInfo.text = "";
		_next = new Button(_scoreBoardList.next, onNextClick);
		_next.enabled = false;
		_prev = new Button(_scoreBoardList.prev, onPrevClick);
		_prev.enabled = false;
		_refresh = new Button(_scoreBoardList.refresh, onRefreshClick);
		_refresh.enabled = false;
		_social = new CheckBox(_scoreBoardList.social);
		_tag = _scoreBoardList.tag;
		_period = new DropDown(cast _scoreBoardList.period);
		_period.addItem("All time"     , Period.ALL);
		_period.addItem("Current day"  , Period.DAY);
		_period.addItem("Current week" , Period.WEEK);
		_period.addItem("Current month", Period.MONTH);
		_period.addItem("Current year" , Period.YEAR);
		_period.value = Period.ALL;
		
		_loadBoards.onClick = loadBoards;
		
		_currentBoard = -1;
	}
	
	function loadBoards():Void {
		
		NG.core.requestScoreBoards(onBoardsLoaded);
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
	
	function onRefreshClick():Void {
		
		getScoresPage(_boardPages.get(_currentBoard), true);
	}
	
	function onPrevClick():Void {
		
		getScoresPage(_boardPages.get(_currentBoard) - 1);
	}
	
	function onNextClick():Void {
		
		getScoresPage(_boardPages.get(_currentBoard) + 1);
	}
	
	function getScores(board:ScoreBoard = null):Void {
		
		if (board == null)
			board = NG.core.scoreBoards.get(_currentBoard);
		else
			_currentBoard = board.id;
		
		var page:Int = _boardPages.get(board.id);
		if (page == -1)
			page = 0;
		
		getScoresPage(page);
	}
	
	function getScoresPage(page:Int, force:Bool = false):Void {
		
		var board = NG.core.scoreBoards.get(_currentBoard);
		
		if (!force && page == _boardPages.get(board.id)) {
			
			showScores(board);
			return;
		}
		
		_next.enabled = false;
		_prev.enabled = false;
		_refresh.enabled = false;
		
		_boardPages.set(board.id, page);
		
		board.onUpdate.addOnce(showScores.bind(board));
		board.requestScores(10, page * 10, _period.value, _social.on, fieldString(_tag));
	}
	
	function showScores(board:ScoreBoard):Void {
		
		if (_boardPages.get(NG.core.scoreBoards.get(_currentBoard).id) > 0)
			_prev.enabled = true;
		_next.enabled = true;
		_refresh.enabled = true;
		
		_boardInfo.text = board.name + "\n\n";
		
		var rank = _boardPages.get(_currentBoard) * 10 + 1;
		
		if (board.scores.length == 0) {
			
			_boardInfo.appendText('no scores listed at rank $rank or higher');
			return;
		}
		
		var maxChars = 
			[ "rank"  => 4
			, "user"  => 30
			, "value" => 5
			, "tag"   => 0
			];
		
		// --- GET MAX CHARS FOR PRETTY PRINT
		for (score in board.scores) {
			var len;
			
			len = getLength(score.user.name);
			if (len > maxChars.get("user"))
				maxChars.set("user", len);
			
			len = getLength(score.formatted_value);
			if (len > maxChars.get("value"))
				maxChars.set("value", len);
			
			len = getLength(score.tag);
			if (len > maxChars.get("tag"))
				maxChars.set("tag", len);
		}
		
		for (score in board.scores) {
			
			_boardInfo.appendText
				( padTo(Std.string(rank           ), maxChars.get("rank" ), true ) + " "
				+ padTo(Std.string(score.user.name), maxChars.get("user" ), true ) + " "
				+ padTo(score.formatted_value      , maxChars.get("value"), false) + " "
				+ padTo(score.tag                  , maxChars.get("tag"  ), true ) + "\n"
				);
			
			rank++;
		}
	}
	
	inline function getLength(value:Dynamic):Int {
		
		if (value == null)
			return 0;
		
		return Std.string(value).length;
	}
	
	inline function padTo(str:String, padding:Int, padRight:Bool = true):String {
		
		if (str == null)
			str = "";
		
		padding -= str.length;
		
		if (padRight) {
			
			while(padding > 0) {
				
				str += " ";
				padding--;
			}
		} else {
			
			while(padding > 0) {
				
				str = " " + str;
				padding--;
			}
		}
		
		return str;
	}
}
#end
	
class CorePageLite extends Page<Component> {
	
	var _login:Button;
	var _loginLabel:TextField;
	var _logout:Button;
	var _host:Input;
	var _sessionId:Input;
	var _user:TextField;
	var _profile:ProfileSwf;
	var _profileButton:Button;
	
	var _loadMedals:Button;
	var _medalList:MedalListSwf;
	
	var _loadBoards:Button;
	var _scoreBoardList:ScoreBoardListSwf;
	var _displayBoards:Map<ScoreBoardSwf, ScoreBoard>;
	
	public function new (target:CorePageSwf) {
		super(null);
		
		_login = new Button(target.login);
		_loginLabel = target.loginLabel;
		_loginLabel.mouseEnabled = false;
		_logout = new Button(target.logout);
		_logout.enabled = false;
		
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
		
		#if ng_lite
		_login.enabled = false;
		_logout.enabled = false;
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