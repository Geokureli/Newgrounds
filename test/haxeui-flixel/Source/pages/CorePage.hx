package pages;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.objects.events.Outcome;

import dialogs.Passport;
import states.MainState;

import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

import flixel.math.FlxPoint;
import openfl.display.BitmapData;

using haxe.ui.animation.AnimationTools;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/core.xml"))
class CorePage extends Page
{
	override function onReady()
	{
		super.onReady();
		
		if (NG.core.loggedIn == false)
		{
			if (NG.core.attemptingLogin)
				login.text = "Cancel";
			else
				onLogout();
		}
		
		NG.core.onLogin.add(onLogin);
		NG.core.onLogOut.add(onLogout);
	}
	
	public function onLogin()
	{
		_main.sessionId.text = NG.core.sessionId;
		login.text = "Logout";
		final user = NG.core.user;
		
		url.fadeIn();
		url.onClick = function (_)
		{
			openUrl('https://${user.name}.newgrounds.com');
		}
		
		if (user.supporter)
			supporter.fadeIn();
		
		username.fadeIn();
		username.text = user.name;
		
		userIcon.fadeIn();
		BitmapData.loadFromFile(user.icons.large)
			.onComplete((bmd)->
			{
				var imageBg = userIcon.members[0];
				var image = userIcon.members[1];
				image.loadGraphic(bmd);
				image.setGraphicSize(Std.int(imageBg.width), Std.int(imageBg.height));
				image.updateHitbox();
			})
			.onError((e)->trace('Error: $e'));//TODO:show error photo
		
		if (NG.core.medals.state == Empty)
		{
			NG.core.medals.loadList(onMedalsRecieve);
		}
	}
	
	public function onLogout()
	{
		login.text = "Login";
		username.fadeOut();
		userIcon.fadeOut();
		supporter.fadeOut();
		url.fadeOut();
	}
	
	@:bind(login, MouseEvent.CLICK)
	function clickLogin(_)
	{
		if (NG.core.loggedIn)
			NG.core.logOut();
		else if (NG.core.attemptingLogin)
		{
			NG.core.cancelLoginRequest();
			login.text = "Login";
		}
		else
			NG.core.requestLogin(null, (url)->{ new Passport().showDialog(); });
	}
	
	function onMedalsRecieve(outcome:Outcome<CallError>)
	{
		switch outcome
		{
			case FAIL(_):
			case SUCCESS:
				for (medal in NG.core.medals)
				{
					
				}
		}
	}
	
	static function openUrl(url:String):Void {
		var window = "_blank";
		
		#if flash
			flash.Lib.getURL(new flash.net.URLRequest(url), window);
		#elseif js
			js.Browser.window.open(url, window);
		#elseif android
			JNI.createStaticMethod
				( "org/haxe/lime/GameActivity"
				, "openURL"
				, "(Ljava/lang/String;Ljava/lang/String;)V"
				) (url, window);
		#elseif sys
			switch Sys.systemName() {
				
				case 'Windows': Sys.command('start ${url}');
				case 'Linux': Sys.command('xdg-open ${url}');
				case 'Mac': Sys.command('open ${url}');
				case name: logError("Unhandled systemName: " + name);
			}
		#else
			logError("Could not open passport url, unhandled target");
		#end
	}
}