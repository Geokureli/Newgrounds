package states;

import js.html.ClipboardEvent;
import states.MainState;
import haxe.ui.containers.Box;
import haxe.ui.components.Label;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;

import flixel.FlxG;

import io.newgrounds.NGLite;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;

class IntroState extends flixel.FlxState
{
	override function create() add(new IntroView());
	// override function create() add(new TestView());
}

@:build(haxe.ui.ComponentBuilder.build("Assets/data/test.xml"))
// class TestView extends haxe.ui.containers.VBox{}
class TestView extends haxe.ui.containers.ScrollView{}

@:build(haxe.ui.ComponentBuilder.build("Assets/data/intro.xml"))
class IntroView extends Box
{
	override function onReady()
	{
		super.onReady();
		
		init();
	}
	
	@:bind(start, MouseEvent.CLICK)
	function clickStart(_)
	{
		FlxG.save.data.appId = appId.text;
		FlxG.save.data.encKey = encKey.text;
		
		var cipher:Cipher = NONE;
		var format:EncodingFormat = BASE_64;
		if (none.selected == false)
		{
			cipher = aes128.selected ? AES_128 : RC4;
			format = base64.selected ? BASE_64 : HEX;
		}
		
		var session = sessionId.text;
		if (StringTools.trim(session) == "")
			session = null;
		
		FlxG.switchState(new MainState
			( appId.text
			, session
			, debug.selected
			, encKey.text
			, cipher
			, format
			)
		);
	}
	
	@:bind(checkLoaderVars, UIEvent.CHANGE)
	function init(?_)
	{
		if (FlxG.save.data.appId != null)
		{
			appId.text = FlxG.save.data.appId;
			encKey.text = FlxG.save.data.encKey;
		}
		
		if (checkLoaderVars.disabled == false)
		{
			var loaderVarSessionId = NGLite.getSessionId();
			if (loaderVarSessionId == null)
			{
				sessionId.text = "";
				checkLoaderVars.disabled = true;
				checkLoaderVars.selected = false;
			}
			
			if (checkLoaderVars.selected)
			{
				sessionId.disabled = true;
				sessionId.text = loaderVarSessionId;
			}
			else
				sessionId.disabled = false;
		}
		
		var saveSession = FlxG.save.data.sessionId;
		if (sessionId.text == "" && saveSession != null)
			sessionId.text = saveSession;
	}
}