package io.newgrounds.test.ui;

import io.newgrounds.components.EventComponent;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.components.MedalComponent;
import io.newgrounds.components.LoaderComponent;
import io.newgrounds.components.GatewayComponent;
import io.newgrounds.components.AppComponent;
import io.newgrounds.components.Component;
import io.newgrounds.objects.Error;
import io.newgrounds.components.ComponentList;
import io.newgrounds.test.utils.SwfUtils;
import io.newgrounds.test.ui.Input;
import io.newgrounds.objects.Medal;

import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.Assets;
import openfl.text.TextField;
import openfl.display.MovieClip;

class Page<T:Component> {
	
	var _target:MovieClip;
	var _calls:T;
	
	public function new(target:MovieClip, component:T) {
		
		_target = target;
	}
	
	
	inline function getMc(path:String):MovieClip {
		
		return SwfUtils.getMc(_target, path);
	}
	
	inline function getField(path:String):TextField {
		
		return SwfUtils.getField(_target, path);
	}
	
	inline function getButton(path:String, onClick:Void->Void = null, onOver:Void->Void = null, onOut:Void->Void = null):Button {
		
		return new Button(SwfUtils.get(_target, path), onClick, onOver, onOut);
	}
	
	inline function getCheckBox(path:String, onToggle:Void->Void = null, onOver:Void->Void = null, onOut:Void->Void = null):CheckBox {
		
		return new CheckBox(SwfUtils.get(_target, path), onToggle);
	}
	
	inline function getInput(path:String, onChange:String->Void = null):Input {
		
		return new Input(SwfUtils.get(_target, path), onChange);
	}
}

class IntroPage extends Page<Component> {
	
	var _appId:TextField;
	var _start:Button;
	var _onStart:Void->Void;
	
	public function new (target:MovieClip, onStart:Void->Void):Void {
		super(target, null);
		
		_appId = getField("appId");
		_start = getButton("start", onStartClick);
		
		_onStart = onStart;
	}
	
	function onStartClick():Void {
		
		NG.createCore(_appId.text);
		NG.core.verbose = true;
		
		_onStart();
	}
}

class CorePage extends Page<Component> {
	
	inline static var DEFAULT_MEDAL_INFO:String = "Roll over a medal for more info, click to unlock.";
	
	var _login:Button;
	var _loginLabel:TextField;
	var _logout:Button;
	var _host:Input;
	var _sessionId:Input;
	
	var _loadMedals:Button;
	var _medalList:MovieClip;
	var _medalInfo:TextField;
	var _medalLoading:TextField;
	var _displayMedals:Array<MovieClip>;
	
	var _loadBoards:Button;
	
	public function new (target:MovieClip) {
		super(target, null);
		
		_login = getButton("login", onLoginClick);
		_loginLabel = getField("loginLabel");
		_loginLabel.mouseEnabled = false;
		_logout = getButton("logout", NG.core.logOut.bind(onLogout));
		_logout.enabled = false;
		_host = getInput("host", onHostChange);
		_sessionId = getInput("sessionId", onSessionIdChange);
		
		_loadMedals = getButton("loadMedals", loadMedals);
		_medalList = getMc("medalList");
		_medalList.visible = false;
		_medalInfo = getField("medalList.info");
		_medalInfo.text = DEFAULT_MEDAL_INFO;
		_medalLoading = getField("medalList.loading");
		_displayMedals = new Array<MovieClip>();
		
		_loadBoards = getButton("loadBoards");//TODO
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
		_medalLoading.visible = true;
		
		while (_displayMedals.length > 0) {
			
			var medal = _displayMedals.pop();
			medal.parent.removeChild(medal);
		}
		
		NG.core.requestMedals(onMedalsLoaded);
	}
	
	function onMedalsLoaded():Void {
		
		_medalLoading.visible = false;
		
		var i:Int = 0;
		var spacing = new Point(50, 65);
		
		for (medalData in NG.core.medals) {
			
			var medal = Assets.getMovieClip("layout:Medal");
			medal.x = (i % 13) * spacing.x;
			medal.y = Math.floor(i / 13) * spacing.y;
			_medalList.addChild(medal);
			SwfUtils.getMc(medal, "lock").visible = !medalData.unlocked;
			SwfUtils.getField(medal, "info").text = '${medalData.value} ${medalData.secret ? "secret" : ""}';
			var loader = new Loader();
			loader.load(new URLRequest(medalData.icon));
			SwfUtils.getMc(medal, "icon").addChild(loader);
			
			_displayMedals.push(medal);
			
			new Button(medal, medalData.unlock().send, showMedalInfo.bind(medalData), hideMedalInfo);
			
			i++;
		}
	}
	
	function updateMedals():Void {
		
		var i:Int = 0;
		var spacing = new Point(50, 65);
		
		for (medalData in NG.core.medals) {
			
			var medal = Assets.getMovieClip("layout:Medal");
			medal.x = (i % 13) * spacing.x;
			medal.y = Math.floor(i / 13) * spacing.y;
			_medalList.addChild(medal);
			SwfUtils.getMc(medal, "lock").visible = !medalData.unlocked;
			SwfUtils.getField(medal, "info").text = '${medalData.value} ${medalData.secret ? "secret" : ""}';
			var loader = new Loader();
			loader.load(new URLRequest(medalData.icon));
			SwfUtils.getMc(medal, "icon").addChild(loader);
			
			_displayMedals.push(medal);
			
			new Button(medal, medalData.unlock().send, showMedalInfo.bind(medalData), hideMedalInfo);
			
			i++;
		}
	}
	
	function showMedalInfo(medal:Medal):Void {
		
		_medalInfo.text = '${medal.name} - ${medal.description}';
	}
	
	function hideMedalInfo():Void {
		
		_medalInfo.text = DEFAULT_MEDAL_INFO;
	}
	
	function onBoardsLoaded():Void {
		
		
	}
}

class AppPage extends Page<AppComponent> {
	
	var _startSession:Button;
	var _force:CheckBox;
	var _checkSession:Button;
	var _endSession:Button;
	var _getHostLicense:Button;
	var _getCurrentVersion:Button;
	var _version:TextField;
	var _logView:Button;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.app);
		
		_force = getCheckBox("force");
		_version = getField("version");
		_startSession      = getButton("startSession"     , function() { _calls.startSession     (_force.on    ).send(); } );
		_checkSession      = getButton("checkSession"     , function() { _calls.checkSession     (             ).send(); } );
		_endSession        = getButton("endSession"       , function() { _calls.endSession       (             ).send(); } );
		_getHostLicense    = getButton("getHostLicense"   , function() { _calls.getHostLicense   (             ).send(); } );
		_getCurrentVersion = getButton("getCurrentVersion", function() { _calls.getCurrentVersion(_version.text).send(); } );
		_logView           = getButton("logView"          , function() { _calls.logView          (             ).send(); } );
	}
}

class EventPage extends Page<EventComponent> {
	
	var _logEvent:Button;
	var _event:TextField;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.event);
		
		_logEvent = getButton("logEvent", function () { _calls.logEvent(_event.text).send(); });
		_event = getField("event");
	}
}

class GatewayPage extends Page<GatewayComponent> {
	
	var _getDatetime:Button;
	var _getVersion:Button;
	var _ping:Button;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.gateway);
		
		_getDatetime = getButton("getDatetime"  , function () { _calls.getDatetime().send(); } );
		_getVersion  = getButton("getVersionBtn", function () { _calls.getVersion ().send(); } );
		_ping        = getButton("ping"         , function () { _calls.ping       ().send(); } );
	}
}

class LoaderPage extends Page<LoaderComponent> {
	
	var _loadAuthorUrl:Button;
	var _loadMoreGames:Button;
	var _loadNewgrounds:Button;
	var _loadOfficialUrl:Button;
	var _loadReferral:Button;
	var _redirect:CheckBox;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.loader);
		
		_loadAuthorUrl   = getButton("loadAuthorUrl"  , function () { _calls.loadAuthorUrl  (_redirect.on).send(); } );
		_loadMoreGames   = getButton("loadMoreGames"  , function () { _calls.loadMoreGames  (_redirect.on).send(); } );
		_loadNewgrounds  = getButton("loadNewgrounds" , function () { _calls.loadNewgrounds (_redirect.on).send(); } );
		_loadOfficialUrl = getButton("loadOfficialUrl", function () { _calls.loadOfficialUrl(_redirect.on).send(); } );
		_loadReferral    = getButton("loadReferral"   , function () { _calls.loadReferral   (_redirect.on).send(); } );
		_redirect = getCheckBox("redirect");
	}
}

class MedalPage extends Page<MedalComponent> {
	
	var _getList:Button;
	var _unlock:Button;
	var _id:TextField;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.medal);
		
		
		_getList = getButton("getList", function () { _calls.getList().send(); } );
		_unlock  = getButton("unlock" , function () { _calls.unlock(Std.parseInt(_id.text)).send(); } );
		_id = getField("id");
	}
}

class ScoreboardPage extends Page<ScoreBoardComponent> {
	
	var _getBoards:Button;
	var _getScores:Button;
	var _limit:TextField;
	var _skip:TextField;
	var _period:TextField;
	var _social:CheckBox;
	var _user:TextField;
	var _postScore:Button;
	var _id:TextField;
	var _tag:TextField;
	var _value:TextField;
	
	public function new (target:MovieClip) {
		super(target, NG.core.calls.scoreBoard);
		
		_limit  = getField("limit");
		_skip   = getField("skip");
		_period = getField("period");
		_user   = getField("user");
		_id     = getField("id");
		_tag    = getField("tag");
		_value  = getField("value");
		
		_social = getCheckBox("social");
		
		_getBoards = getButton("getBoards", function () { _calls.getBoards().send(); });
		_getScores = getButton("getScores",
			function ():Void {
				
				_calls.getScores
					( Std.parseInt(_id.text)
					, Std.parseInt(_limit.text)
					, Std.parseInt(_skip.text)
					, _period.text
					, _social.on
					, _tag.text
					, _user.text
					)
					.send();
			}
		);
		_postScore = getButton("postScore",
			function () {
				
				_calls.postScore(Std.parseInt(_id.text), Std.parseInt(_value.text), _tag.text)
					.send();
			}
		);
	
	}
}
