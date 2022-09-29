package states;

import haxe.PosInfos;

import pages.*;

import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

import io.newgrounds.NG;
import io.newgrounds.NGLite;
import io.newgrounds.Call;
import io.newgrounds.components.*;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Response;

class MainState extends flixel.FlxState
{
    var view:MainView;
    
    public function new
    ( appId    :String
    , sessionId:String
    , debug    :Bool
    , encKey   :String
    , cipher   :Cipher
    , format   :EncodingFormat
    ) {
        super();
        
        NG.create(appId, sessionId, debug, loginOutcome);
        if (cipher != NONE)
            NG.core.setupEncryption(encKey, cipher, format);
        
        NG.core.verbose = true;
    }
    
    override function create()
    {
        add(view = new MainView());
    }
    
    function loginOutcome(outcome:LoginOutcome)
    {
        switch outcome
        {
            case SUCCESS: view.onLogin();
            case FAIL(_):
        }
    }
}

@:build(haxe.ui.ComponentBuilder.build("Assets/data/main.xml"))
class MainView extends VBox
{
    public var core      (default, null):CorePage;
    public var app       (default, null):AppPage;
    public var event     (default, null):EventPage;
    public var gateway   (default, null):GatewayPage;
    public var loader    (default, null):LoaderPage;
    public var medal     (default, null):MedalPage;
    public var scoreBoard(default, null):ScoreBoardPage;
    public var cloudSave (default, null):CloudSavePage;
    
    public function new ()
    {
        super();
        
        core       = new CorePage      ();
        app        = new AppPage       ();
        event      = new EventPage     ();
        gateway    = new GatewayPage   ();
        loader     = new LoaderPage    ();
        medal      = new MedalPage     ();
        scoreBoard = new ScoreBoardPage();
        cloudSave  = new CloudSavePage ();
        
        corePage      .addComponent(core      .init(this));
        appPage       .addComponent(app       .init(this));
        eventPage     .addComponent(event     .init(this));
        gatewayPage   .addComponent(gateway   .init(this));
        loaderPage    .addComponent(loader    .init(this));
        medalPage     .addComponent(medal     .init(this));
        scoreBoardPage.addComponent(scoreBoard.init(this));
        cloudSavePage .addComponent(cloudSave .init(this));
        
        NG.core.log = log;
        var url = NGLite.getUrl();
        if (url != null)
            NG.core.host = host.text = url;
    }
    
    
    @:allow(states.MainState)
    function onLogin()
    {
        sessionId.text = NG.core.sessionId;
        core.onLogin();
    }
    
    @:bind(sessionId, UIEvent.CHANGE)
    function changeSessionId(_)
    {
        NG.core.sessionId = sessionId.text;
    }
    
    @:bind(host, UIEvent.CHANGE)
    function changeHost(_)
    {
        NG.core.host = host.text;
    }
    
    public function log(msg:String, ?pos:PosInfos)
    {
        haxe.Log.trace(msg, pos);
        
        console.text += '$msg\n';
    }
    
    public function logOutcome<T>(callOutcome:CallOutcome<T>)
    {
        switch callOutcome
        {
            case FAIL(HTTP(error)):
                setOutcome('Latest Outcome: Http Error', error);
            case FAIL(RESPONSE(error)):
                setOutcome('Response Error', error.toString());
            case FAIL(RESULT(error)):
                setOutcome('Result Error', error.toString());
            case SUCCESS(data):
                setOutcome('Success', haxe.Json.stringify(data));
        }
    }
    
    public function setOutcome(headerText:String, outcomeText:String)
    {
        outcomeHeader.text = 'Latest Outcome: $headerText';
        outcome.text = outcomeText;
    }
}