package io.newgrounds.test.ui;

import io.newgrounds.test.art.AppPageSwf;
import io.newgrounds.test.art.ScoreboardPageSwf;
import io.newgrounds.test.art.MedalPageSwf;
import io.newgrounds.test.art.LoaderPageSwf;
import io.newgrounds.test.art.GatewayPageSwf;
import io.newgrounds.test.art.EventPageSwf;
import io.newgrounds.components.EventComponent;
import io.newgrounds.components.ScoreBoardComponent;
import io.newgrounds.components.MedalComponent;
import io.newgrounds.components.LoaderComponent;
import io.newgrounds.components.GatewayComponent;
import io.newgrounds.components.AppComponent;
import io.newgrounds.components.Component;

import openfl.text.TextField;
import openfl.display.MovieClip;

class Page<T:Component> {
	
	var _calls:T;
	
	public function new(component:T = null) {
		
		_calls = component;
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
	
	public function new (target:AppPageSwf) {
		super(NG.core.calls.app);
		
		_force = new CheckBox(target.force);
		_version = target.version;
		_startSession      = new Button(target.startSession     , function() { _calls.startSession     (_force.on    ).send(); } );
		_checkSession      = new Button(target.checkSession     , function() { _calls.checkSession     (             ).send(); } );
		_endSession        = new Button(target.endSession       , function() { _calls.endSession       (             ).send(); } );
		_getHostLicense    = new Button(target.getHostLicense   , function() { _calls.getHostLicense   (             ).send(); } );
		_getCurrentVersion = new Button(target.getCurrentVersion, function() { _calls.getCurrentVersion(_version.text).send(); } );
		_logView           = new Button(target.logView          , function() { _calls.logView          (             ).send(); } );
	}
}

class EventPage extends Page<EventComponent> {
	
	var _logEvent:Button;
	var _event:TextField;
	
	public function new (target:EventPageSwf) {
		super(NG.core.calls.event);
		
		_logEvent = new Button(target.logEvent, function () { _calls.logEvent(_event.text).send(); });
		_event = target.event;
	}
}

class GatewayPage extends Page<GatewayComponent> {
	
	var _getDatetime:Button;
	var _getVersion:Button;
	var _ping:Button;
	
	public function new (target:GatewayPageSwf) {
		super(NG.core.calls.gateway);
		
		_getDatetime = new Button(target.getDatetime  , function () { _calls.getDatetime().send(); } );
		_getVersion  = new Button(target.getVersionBtn, function () { _calls.getVersion ().send(); } );
		_ping        = new Button(target.ping         , function () { _calls.ping       ().send(); } );
	}
}

class LoaderPage extends Page<LoaderComponent> {
	
	var _loadAuthorUrl:Button;
	var _loadMoreGames:Button;
	var _loadNewgrounds:Button;
	var _loadOfficialUrl:Button;
	var _loadReferral:Button;
	var _redirect:CheckBox;
	
	public function new (target:LoaderPageSwf) {
		super(NG.core.calls.loader);
		
		_loadAuthorUrl   = new Button(target.loadAuthorUrl  , function () { _calls.loadAuthorUrl  (_redirect.on).send(); } );
		_loadMoreGames   = new Button(target.loadMoreGames  , function () { _calls.loadMoreGames  (_redirect.on).send(); } );
		_loadNewgrounds  = new Button(target.loadNewgrounds , function () { _calls.loadNewgrounds (_redirect.on).send(); } );
		_loadOfficialUrl = new Button(target.loadOfficialUrl, function () { _calls.loadOfficialUrl(_redirect.on).send(); } );
		_loadReferral    = new Button(target.loadReferral   , function () { _calls.loadReferral   (_redirect.on).send(); } );
		_redirect = new CheckBox(target.redirect);
	}
}

class MedalPage extends Page<MedalComponent> {
	
	var _getList:Button;
	var _unlock:Button;
	var _id:TextField;
	
	public function new (target:MedalPageSwf) {
		super(NG.core.calls.medal);
		
		_getList = new Button(target.getList, function () { _calls.getList().send(); } );
		_unlock  = new Button(target.unlock , function () { _calls.unlock(Std.parseInt(_id.text)).send(); } );
		_id = target.id;
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
	
	public function new (target:ScoreboardPageSwf) {
		super(NG.core.calls.scoreBoard);
		
		_limit  = target.limit;
		_skip   = target.skip;
		_period = target.period;
		_user   = target.user;
		_id     = target.id;
		_tag    = target.tag;
		_value  = target.value;
		
		_social = new CheckBox(target.social);
		
		_getBoards = new Button(target.getBoards, function () { _calls.getBoards().send(); });
		_getScores = new Button(target.getScores,
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
		_postScore = new Button(target.postScore,
			function () {
				
				_calls.postScore(Std.parseInt(_id.text), Std.parseInt(_value.text), _tag.text)
					.send();
			}
		);
	
	}
}
