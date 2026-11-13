package ngio.test.ui;

import haxe.PosInfos;
import haxe.ds.StringMap;
import io.newgrounds.test.art.MainScreenSwf;
import ngio.NG;
import ngio.data.AppData;
import ngio.swf.common.Button;
import ngio.test.ui.CloudSavePage;
import ngio.test.ui.Page;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;

class MainScreen extends Sprite {
	
	static inline var CORE      :String = "core";
	static inline var APP       :String = "app";
	static inline var ASSETS    :String = "assets";
	static inline var EVENT     :String = "event";
	static inline var GATEWAY   :String = "gateway";
	static inline var LOADER    :String = "loader";
	static inline var MEDAL     :String = "medal";
	static inline var SCOREBOARD:String = "scoreboard";
	static inline var CLOUD_SAVE:String = "cloudSave";
	
	static var _pageWrappers:StringMap<Class<Dynamic>>;
	
	var _layout:MainScreenSwf;
	var _tabs:StringMap<Button>;
	var _pages:StringMap<MovieClip>;
	var _currentPage:String;
	var _output:TextField;
	var _clear:Button;
	var _queue:CheckBox;
	
	public function new(app:AppData) {
		
		super();
		
		_pageWrappers = 
		[ CORE       => CorePage
		, APP        => AppPage
		, ASSETS     => AssetsPage
		, EVENT      => EventPage
		, GATEWAY    => GatewayPage
		, LOADER     => LoaderPage
		, MEDAL      => MedalPage
		, SCOREBOARD => ScoreboardPage
		, CLOUD_SAVE => CloudSavePage
		];
		
		
		NG.create(app);
		
		NG.core.logger.verbose = true;
		
		// cache log messages that happen before initialization
		var queuedOutput = new Array<{msg:String, pos:PosInfos}>();
		NG.core.logger.log = function (msg, ?pos) queuedOutput.push({msg:msg, pos:pos});
		
		_layout = new MainScreenSwf();
		addChild(_layout);
		#if js
			Input.mouseDisableText(_layout);
		#end
		_output = _layout.output;
		_output.text = "";
		NG.core.logger.log = logOutput;
		// log the early messages
		while (queuedOutput.length > 0) {
			
			var next = queuedOutput.shift();
			logOutput(next.msg, next.pos);
		}
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	function onAdded(event:Event):Void {
		_currentPage = null;
		
		_clear = new Button(_layout.clear, function ():Void { _output.text = ""; });
		_queue = new CheckBox(_layout.queue, function ():Void { Page.queueCalls = _queue.on; });
		
		_tabs = new StringMap<Button>();
		_pages = new StringMap<MovieClip>();
		
		for (name in _pageWrappers.keys()) {
			
			_tabs.set(name, new Button(cast _layout.getChildByName(name + "Tab"), onTabClick.bind(name)));
			_pages.set(name, cast _layout.getChildByName(name));
			_pages.get(name).visible = false;
			Type.createInstance(_pageWrappers.get(name), [_pages.get(name)]);
		}
		
		onTabClick(CORE);
	}
	
	function onTabClick(name:String):Void {
		
		if (_currentPage != null) {
			
			_pages.get(_currentPage).visible = false;
			_tabs.get(_currentPage).enabled = true;
		}
		
		_tabs.get(name).enabled = false;
		_pages.get(name).visible = true;
		
		_currentPage = name;
	}
	
	function logOutput(msg:Any, ?pos:PosInfos):Void {
		
		_output.appendText('$msg\n');
		_output.setSelection(_output.text.length, _output.text.length);
	}
}