package io.newgrounds.test.ui;

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

class Page {
	
	var _target:MovieClip;
	var _calls:ComponentList;
	
	public function new(target:MovieClip) {
		
		_target = target;
		
		if (NG.core != null)
			_calls = NG.core.calls;
	}
	
	
	inline function getMc(path:String):MovieClip {
		
		return SwfUtils.getMc(_target, path);
	}
	
	inline function getField(path:String):TextField {
		
		return SwfUtils.getField(_target, path);
	}
	
}

class IntroPage extends Page {
	
	var _appId:TextField;
	var _start:Button;
	var _onStart:Void->Void;
	
	public function new (target:MovieClip, onStart:Void->Void):Void {
		super(target);
		
		_appId = getField("appId");
		_start = new Button(getMc("start"), onStartClick);
		
		_onStart = onStart;
	}
	
	function onStartClick():Void {
		
		NG.createCore(_appId.text);
		NG.core.verbose = true;
		
		_onStart();
	}
}

class CorePage extends Page {
	
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
		super(target);
		
		_login = new Button(getMc("login"), onLoginClick);
		_loginLabel = getField("loginLabel");
		_loginLabel.mouseEnabled = false;
		_logout = new Button(getMc("logout"), NG.core.logOut.bind(onLogout));
		_logout.enabled = false;
		_host = new Input(getField("host"), onHostChange);
		_sessionId = new Input(getField("sessionId"), onSessionIdChange);
		
		_loadMedals = new Button(getMc("loadMedals"), loadMedals);
		_medalList = getMc("medalList");
		_medalList.visible = false;
		_medalInfo = getField("medalList.info");
		_medalInfo.text = DEFAULT_MEDAL_INFO;
		_medalLoading = getField("medalList.loading");
		_displayMedals = new Array<MovieClip>();
		
		_loadBoards = new Button(getMc("loadBoards"), null);//TODO
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

class AppPage extends Page {
	
	var _startSession:Button;
	var _force:CheckBox;
	var _checkSession:Button;
	var _endSession:Button;
	
	public function new (target:MovieClip) {
		super(target);
		
		_startSession = new Button(getMc("startSession"), function() { _calls.app.startSession(_force.on).send(); } );
		_force = new CheckBox(getMc("force"));
		_checkSession = new Button(getMc("checkSession"), function() { _calls.app.checkSession().send(); });
		_endSession = new Button(getMc("endSession"), function() { _calls.app.endSession().send(); });
	}
}

class EventPage extends Page {
	
	var _logEvent:Button;
	var _event:TextField;
	
	public function new (target:MovieClip) {
		super(target);
		
		_logEvent = new Button(getMc("logEvent"), function () { _calls.event.logEvent(_event.text).send(); });
		_event = getField("event");
	}
}

class GatewayPage extends Page {
	
	var _getDatetime:Button;
	var _getVersion:Button;
	var _ping:Button;
	
	public function new (target:MovieClip) {
		super(target);
		
		_getDatetime = new Button(getMc("getDatetime"), function () { _calls.gateway.getDatetime().send(); });
		_getVersion = new Button(getMc("getVersionBtn"), function () { _calls.gateway.getVersion().send(); });
		_ping = new Button(getMc("ping"), _calls.gateway.ping);
	}
}

class LoaderPage extends Page {
	
	var _loadAuthorUrl:Button;
	var _loadMoreGames:Button;
	var _loadNewgrounds:Button;
	var _loadOfficialUrl:Button;
	var _loadReferral:Button;
	var _redirect:CheckBox;
	
	public function new (target:MovieClip) {
		super(target);
		
		_loadAuthorUrl   = new Button(getMc("loadAuthorUrl"  ), function () { _calls.loader.loadAuthorUrl  (_redirect.on).send(); } );
		_loadMoreGames   = new Button(getMc("loadMoreGames"  ), function () { _calls.loader.loadMoreGames  (_redirect.on).send(); } );
		_loadNewgrounds  = new Button(getMc("loadNewgrounds" ), function () { _calls.loader.loadNewgrounds (_redirect.on).send(); } );
		_loadOfficialUrl = new Button(getMc("loadOfficialUrl"), function () { _calls.loader.loadOfficialUrl(_redirect.on).send(); } );
		_loadReferral    = new Button(getMc("loadReferral"   ), function () { _calls.loader.loadReferral   (_redirect.on).send(); } );
		_redirect = new CheckBox(getMc("redirect"));
	}
}

class MedalPage extends Page {
	
	var _getList:Button;
	var _unlock:Button;
	var _id:TextField;
	
	public function new (target:MovieClip) {
		super(target);
		
		
		_getList = new Button(getMc("getList"), _calls.medal.getList);
		_unlock = new Button(getMc("unlock"), function () { _calls.medal.unlock(Std.parseInt(_id.text)).send(); } );
		_id = getField("id");
	}
}

class ScoreboardPage extends Page {
	
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
		super(target);
		
		_limit = getField("limit");
		_skip = getField("skip");
		_period = getField("period");
		_user = getField("user");
		_id = getField("id");
		_tag = getField("tag");
		_value = getField("value");
		_social = new CheckBox(getMc("social"));
		
		_getBoards = new Button(getMc("getBoards"), function () { _calls.scoreBoard.getBoards().send(); });
		_getScores = new Button(getMc("getScores"),
			function getScores():Void {
				
				_calls.scoreBoard.getScores
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
		_postScore = new Button(getMc("postScore"),
			function () {
				
				_calls.scoreBoard.postScore(Std.parseInt(_id.text), Std.parseInt(_value.text), _tag.text)
					.send();
			}
		);
	
	}
}
