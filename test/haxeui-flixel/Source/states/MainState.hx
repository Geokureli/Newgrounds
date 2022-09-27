package states;

import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.components.*;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Response;

using haxe.ui.animation.AnimationTools;

class MainState extends flixel.FlxState
{
    public function new
    ( appId    :String
    , sessionId:String
    , debug    :Bool
    , encKey   :String
    , cipher   :Cipher
    , format   :EncodingFormat
    ) {
        super();
        
        NG.create(appId, sessionId, debug);
        if (cipher != NONE)
            NG.core.setupEncryption(encKey, cipher, format);
    }
    
    override function create()
    {
        add(new MainView());
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/main.xml"))
class MainView extends VBox
{
    public function new()
    {
        super();
        
        corePage.addComponent(new CorePage());
        appPage.addComponent(new AppPage().init(this));
        eventPage.addComponent(new EventPage().init(this));
        gatewayPage.addComponent(new GatewayPage().init(this));
        loaderPage.addComponent(new LoaderPage().init(this));
        medalPage.addComponent(new MedalPage().init(this));
        scoreboardPage.addComponent(new ScoreboardPage().init(this));
        cloudSavePage.addComponent(new CloudSavePage().init(this));
    }
    
    public function log(msg:String)
    {
        console.text += '$msg\n';
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/core.xml"))
class CorePage extends VBox
{
    
}

class Page<C:Component> extends VBox
{
    var _main:MainView;
    var _component:C;
    var _componentName:String;
    
    public function new()
    {
        super();
        
        _componentName = id;
    }
    
    public function init (main:MainView)
    {
        _main = main;
        return this;
    }
    
    function logCall(callName:String, args:Any)
    {
        main.log('CALL: $_componentName.$callName(${argsToString(args)})');
    }
    
    inline function argsToString(args:Null<Dynamic>)
    {
        return args != null ? haxe.Json.stringify(args) : "";
    }
    
    function send<T:ResultBase>(call:Call<T>)
    {
        // call.addResponseHandler(onServerRespond);
    }
    
    function onServerRespond<T:ResultBase>(response:Response<T>)
    {
        _main.log('RESPONSE: $response');
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

@:build(haxe.ui.ComponentBuilder.build("assets/pages/app.xml"))
class AppPage extends Page<AppComponent>
{
    public function new()
    {
        _component = NG.core.calls.app;
        super();
    }
    
    @:bind(startSession, MouseEvent.CLICK)
    function clickStartSession(e:MouseEvent)
    {
        send(_component.startSession(force.selected));
        // logCall('startSession', { force: force.selected });
    }
    
    // @:bind(checkSession, MouseEvent.CLICK)
    // function clickCheckSession(_) logCall('checkSession');
    
    // @:bind(endSession, MouseEvent.CLICK)
    // function clickEndSession(_) logCall('endSession');
    
    // @:bind(getHostLicense, MouseEvent.CLICK)
    // function clickGetHostLicense(_) logCall('getHostLicense');
    
    // @:bind(logView, MouseEvent.CLICK)
    // function clickLogView(_) logCall('logView');
    
    @:bind(getCurrentVersion, MouseEvent.CLICK)
    function clickGetCurrentVersion(_)
    {
        if (flashInvalidText(version))
            return;
        
        // logCall('getCurrentVersion', { version: version.text });
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/event.xml"))
class EventPage extends Page<EventComponent>
{
    public function new()
    {
        _component = NG.core.calls.event;
        super();
    }
    
    @:bind(logEvent, MouseEvent.CLICK)
    function clickLogEvent(_)
    {
        if (flashInvalidText(event))
            return;
        
        // logCall('logEvent', { event:event.text });
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/gateway.xml"))
class GatewayPage extends Page<GatewayComponent>
{
    public function new()
    {
        _component = NG.core.calls.gateway;
        super();
    }
    
    // @:bind(getDateTime, MouseEvent.CLICK)
    // function clickGetDateTime(_) logCall('getDateTime');
    
    // @:bind(getVersion, MouseEvent.CLICK)
    // function clickGetVersion(_) logCall("getVersion");
    
    // @:bind(ping, MouseEvent.CLICK)
    // function clickPing(_) logCall("ping");
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/loader.xml"))
class LoaderPage extends Page<LoaderComponent>
{
    public function new()
    {
        _component = NG.core.calls.loader;
        super();
    }
    
    // @:bind(loadAuthorUrl, MouseEvent.CLICK)
    // function clickLoadAuthorUrl(_) logCall("loadAuthorUrl", { redirect: redirect.selected });
    
    // @:bind(loadMoregames, MouseEvent.CLICK)
    // function clickLoadMoregames(_) logCall("loadMoregames", { redirect: redirect.selected });
    
    // @:bind(loadNewgrounds, MouseEvent.CLICK)
    // function clickLoadNewgrounds(_) logCall("loadNewgrounds", { redirect: redirect.selected });
    
    // @:bind(loadOfficialUrl, MouseEvent.CLICK)
    // function clickLoadOfficialUrl(_) logCall("loadOfficialUrl", { redirect: redirect.selected });
    
    // @:bind(loadReferral, MouseEvent.CLICK)
    // function clickLoadReferral(_) logCall("loadReferral", { redirect: redirect.selected });
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/medal.xml"))
class MedalPage extends Page<MedalComponent>
{
    public function new()
    {
        _component = NG.core.calls.medal;
        super();
    }
    
    // @:bind(getList, MouseEvent.CLICK)
    // function clickGetList(_) logCall("getList");
    
    @:bind(unlock, MouseEvent.CLICK)
    function clickUnlock(_)
    {
        if (flashInvalidText(medalId))
            return;
        
        // logCall("unlock", { id:medalId.text });
    }
    
    // @:bind(getMedalScore, MouseEvent.CLICK)
    // function clickGetMedalScore(_) logCall("getMedalScore");
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/scoreboard.xml"))
class ScoreboardPage extends Page<ScoreboardComponent>
{
    public function new()
    {
        _component = NG.core.calls.scoreboard;
        super();
    }
    
    // @:bind(getBoards, MouseEvent.CLICK)
    // function clickGetBoards(_) logCall("getBoards");
    
    @:bind(getScores, MouseEvent.CLICK)
    function clickGetScores(_) 
    {
        final periodValues = [DAY, WEEK, MONTH, YEAR, ALL];
        // logCall("getScores",
        //     { limit : limit.pos
        //     , skip  : skip.pos
        //     , period: periodValues[period.selectedIndex];
        //     , social: social.selected
        //     , user  : user.text
        //     }
        // );
    }
    
    @:bind(postScore, MouseEvent.CLICK)
    function clickPostScore(_)
    {
        if (flashInvalidText(score))
            return;
        
        // logCall("postScore", { score:score.text });
    }
}

@:build(haxe.ui.ComponentBuilder.build("assets/pages/cloudsaves.xml"))
class CloudSavePage extends Page<CloudSaveComponent>
{
    public function new()
    {
        _component = NG.core.calls.cloudSave;
        super();
    }
}