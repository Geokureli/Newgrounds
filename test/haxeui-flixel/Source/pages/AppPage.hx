package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/app.xml"))
class AppPage extends Page
{
    @:bind(startSession, MouseEvent.CLICK)
    function clickStartSession(e:MouseEvent)
    {
        send(NG.core.calls.app.startSession(force.selected));
    }
    
    @:bind(checkSession, MouseEvent.CLICK)
    function clickCheckSession(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.app.checkSession());
    }
    
    @:bind(endSession, MouseEvent.CLICK)
    function clickEndSession(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.app.endSession());
    }
    
    @:bind(getHostLicense, MouseEvent.CLICK)
    function clickGetHostLicense(_)
    {
        if (flashInvalidHost()) return;
        send(NG.core.calls.app.getHostLicense());
    }
    
    @:bind(logView, MouseEvent.CLICK)
    function clickLogView(_)
    {
        if (flashInvalidHost()) return;
        send(NG.core.calls.app.logView());
    }
    
    @:bind(getCurrentVersion, MouseEvent.CLICK)
    function clickGetCurrentVersion(_)
    {
        if (flashInvalidText(version)) return;
        send(NG.core.calls.app.getCurrentVersion(version.text));
    }
}