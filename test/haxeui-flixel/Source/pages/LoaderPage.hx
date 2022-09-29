package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/loader.xml"))
class LoaderPage extends Page
{
    @:bind(loadAuthorUrl, MouseEvent.CLICK)
    function clickLoadAuthorUrl(_)
    {
        send(NG.core.calls.loader.loadAuthorUrl(redirect.selected));
    }
    
    @:bind(loadMoreGames, MouseEvent.CLICK)
    function clickLoadMoreGames(_)
    {
        send(NG.core.calls.loader.loadMoreGames(redirect.selected));
    }
    
    @:bind(loadNewgrounds, MouseEvent.CLICK)
    function clickLoadNewgrounds(_)
    {
        send(NG.core.calls.loader.loadNewgrounds(redirect.selected));
    }
    
    @:bind(loadOfficialUrl, MouseEvent.CLICK)
    function clickLoadOfficialUrl(_)
    {
        send(NG.core.calls.loader.loadOfficialUrl(redirect.selected));
    }
    
    @:bind(loadReferral, MouseEvent.CLICK)
    function clickLoadReferral(_)
    {
        if (flashInvalidHost()) return;
        if (flashInvalidText(referralName)) return;
        send(NG.core.calls.loader.loadReferral(referralName.text, logStat.selected, redirect.selected));
    }
}
