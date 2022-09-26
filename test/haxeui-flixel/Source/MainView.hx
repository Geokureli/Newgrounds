package ;

import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox
{
    public function new()
    {
        super();
    // }
    
    // override function onReady()
    // {
    //     super.onReady();
        
        appPage.addComponent(new EventPage().init(this, "App"));
        eventPage.addComponent(new EventPage().init(this, "Event"));
        gatewayPage.addComponent(new GatewayPage().init(this, "Gateway"));
        loaderPage.addComponent(new LoaderPage().init(this, "Loader"));
        medalPage.addComponent(new MedalPage().init(this, "Medal"));
        scoreboardPage.addComponent(new ScoreboardPage().init(this, "Scoreboard"));
        cloudSavePage.addComponent(new CloudSavePage().init(this, "CloudSave"));
    }
    
    public function log(msg:String)
    {
        console.text += '$msg\n';
    }
}

class Page extends VBox
{
    var logCall:(String, ?Dynamic)->Void;
    
    public function init (main:MainView, name:String)
    {
        logCall = function (methodName, ?args)
        {
            main.log('$name.$methodName(${argsToString(args)})');
        }
        return this;
    }
    
    inline function argsToString(args:Null<Dynamic>)
    {
        return args != null ? haxe.Json.stringify(args) : "";
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/app-page.xml"))
class AppPage extends Page
{
    @:bind(startSession, MouseEvent.CLICK)
    function clickStartSession(e:MouseEvent) logCall('startSession');
    
    @:bind(checkSession, MouseEvent.CLICK)
    function clickCheckSession(_) logCall('checkSession');
    
    @:bind(endSession, MouseEvent.CLICK)
    function clickEndSession(_) logCall('endSession');
    
    @:bind(getHostLicense, MouseEvent.CLICK)
    function clickGetHostLicense(_) logCall('getHostLicense');
    
    @:bind(logView, MouseEvent.CLICK)
    function clickLogView(_) logCall('logView');
    
    @:bind(getCurrentVersion, MouseEvent.CLICK)
    function clickGetCurrentVersion(_) logCall('getCurrentVersion', {version: version.text});
}

@:build(haxe.ui.ComponentBuilder.build("assets/event-page.xml"))
class EventPage extends Page
{
    @:bind(logEvent, MouseEvent.CLICK)
    function clickLogEvent(_) logCall('logEvent', { event:${this.event} });
}

@:build(haxe.ui.ComponentBuilder.build("assets/gateway-page.xml"))
class GatewayPage extends Page
{
    @:bind(getDateTime, MouseEvent.CLICK)
    function clickGetDateTime(_) logCall('getDateTime');
    
    @:bind(getVersion, MouseEvent.CLICK)
    function clickGetVersion(_) logCall("getVersion()");
    
    @:bind(ping, MouseEvent.CLICK)
    function clickPing(_) logCall("ping");
}

@:build(haxe.ui.ComponentBuilder.build("assets/loader-page.xml"))
class LoaderPage extends Page {}

@:build(haxe.ui.ComponentBuilder.build("assets/medal-page.xml"))
class MedalPage extends Page {}

@:build(haxe.ui.ComponentBuilder.build("assets/scoreboard-page.xml"))
class ScoreboardPage extends Page {}

@:build(haxe.ui.ComponentBuilder.build("assets/cloudsaves-page.xml"))
class CloudSavePage extends Page {}