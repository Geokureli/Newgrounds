package io.newgrounds.test.ui;

import io.newgrounds.swf.common.Button;
import haxe.ds.StringMap;
import haxe.PosInfos;

import openfl.events.Event;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.MovieClip;

import io.newgrounds.test.art.MainScreenSwf;
import io.newgrounds.test.ui.Page;
import io.newgrounds.NG;

class MainScreen extends Sprite {
	
	static inline var CORE      :String = "core";
	static inline var APP       :String = "app";
	static inline var ASSETS    :String = "assets";
	static inline var EVENT     :String = "event";     
	static inline var GATEWAY   :String = "gateway";
	static inline var LOADER    :String = "loader";
	static inline var MEDAL     :String = "medal";
	static inline var SCOREBOARD:String = "scoreboard";
	
	static var _pageWrappers:StringMap<Class<Dynamic>>;
	
	var _layout:MainScreenSwf;
	var _tabs:StringMap<Button>;
	var _pages:StringMap<MovieClip>;
	var _currentPage:String;
	var _output:TextField;
	var _clear:Button;
	var _queue:CheckBox;
	
	public function new () {
		
		super ();
		
		_pageWrappers = 
		[ CORE       => CorePage
		, APP        => AppPage
		, ASSETS     => AssetsPage
		, EVENT      => EventPage
		, GATEWAY    => GatewayPage
		, LOADER     => LoaderPage
		, MEDAL      => MedalPage
		, SCOREBOARD => ScoreboardPage
		];
		
		NG.core.log = logOutput;
		
		_layout = new MainScreenSwf();
		addChild(_layout);
		#if js
			Input.mouseDisableText(_layout);
		#end
		_output = _layout.output;
		_output.text = "";
		
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
	
	function logOutput(msg:String, ?pos:PosInfos):Void {
		
		_output.appendText(msg + "\n");
		_output.setSelection(_output.text.length, _output.text.length);
	}
}