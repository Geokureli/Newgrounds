package pages;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.objects.events.Outcome;

import components.CloudSaves;
import components.ScoreBoard;
import dialogs.Passport;
import states.MainState;

import flixel.FlxG;

import haxe.ui.containers.Box;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

import flixel.math.FlxPoint;
import openfl.display.BitmapData;

using haxe.ui.animation.AnimationTools;
using StringTools;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/core.xml"))
class CorePage extends Page
{
	var cloudSaves:CloudSaves;
	var scoreBoard:ScoreBoard;
	
	public function new ()
	{
		super();
		
		cloudSaveContainer.addComponent(cloudSaves = new CloudSaves());
		scoreBoardContainer.addComponent(scoreBoard = new ScoreBoard());
	}
	
	override function onReady()
	{
		super.onReady();
		
		if (NG.core.loggedIn == false)
		{
			if (NG.core.attemptingLogin)
				login.text = "Cancel";
			else
			{
				username.hidden = true;
				userIcon.hidden = true;
				supporter.hidden = true;
				url.hidden = true;
			}
		}
		
		NG.core.onLogin.add(onLogin);
		NG.core.onLogOut.add(onLogout);
	}
	
	public function onLogin()
	{
		FlxG.save.data.sessionId = NG.core.sessionId;
		FlxG.save.flush();
		
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
				final key = 'user-icon:${user.name}';
				FlxG.bitmap.add(bmd, false, key);
				userIcon.resource = key;
			})
			.onError((e)->userIcon.resource = "Assets/images/pfp.png");
		
		if (NG.core.medals.state == Empty)
			NG.core.medals.loadList(onMedalsReceive);
		
		if (NG.core.scoreBoards.state == Empty)
			scoreBoard.loadBoards();
		
		if (NG.core.saveSlots.state == Empty)
			cloudSaves.loadSlots();
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
	
	function onMedalsReceive(outcome:Outcome<CallError>)
	{
		switch outcome
		{
			case FAIL(_):
			case SUCCESS:
			{
				for (medal in NG.core.medals)
				{
					medalList.addComponent(new MedalItem(medal.icon, medal.unlocked));
				}
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
				case name: NG.core.logError("Unhandled systemName: " + name);
			}
		#else
			NG.core.logError("Could not open passport url, unhandled target");
		#end
	}
}

@:build(haxe.ui.ComponentBuilder.build("Assets/data/components/medal.xml"))
class MedalItem extends Box
{
	public function new (url:String, unlocked:Bool)
	{
		super();
		
		if (url.endsWith("medal_secret.png"))
			url = "Assets/images/medal_secret.png";
		else if (url.indexOf("//") == 0)
			url = "https:" + url;
		
		medalIcon.resource = url;
		lock.hidden = unlocked;
	}
}