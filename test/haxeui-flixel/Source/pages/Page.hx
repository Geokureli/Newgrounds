package pages;

import states.MainState;

import haxe.ui.containers.VBox;
import haxe.ui.components.TextField;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.components.ComponentList;
import io.newgrounds.objects.events.Result;

using haxe.ui.animation.AnimationTools;

class Page extends VBox
{
	var _main:MainView;
	
	public function init(main:MainView)
	{
		_main = main;
		return this;
	}
	
	function send<T:BaseData>(call:Call<T>)
	{
		call.addOutcomeHandler(_main.logOutcome).send();
	}
	
	function flashInvalidSession()
	{
		return flashInvalidText(_main.sessionId);
	}
	
	function flashInvalidHost()
	{
		return flashInvalidText(_main.host);
	}
	
	function validText(field:TextField)
	{
		return field.text == null || StringTools.trim(field.text) == "";
	}
	
	function flashInvalidTextAll(fields:Array<TextField>)
	{
		var fail = false;
		for (field in fields)
			fail = fail || flashInvalidText(field);
		
		return false;
	}
	
	function flashInvalidText(field:TextField)
	{
		if (validText(field))
		{
			field.shake().shake("vertical").flash();
			return true;
		}
		
		return false;
	}
}