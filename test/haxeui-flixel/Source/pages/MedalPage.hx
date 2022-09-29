package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/medal.xml"))
class MedalPage extends Page
{
    @:bind(getList, MouseEvent.CLICK)
    function clickGetList(_)
    {
        send(NG.core.calls.medal.getList());
    }
    
    @:bind(unlock, MouseEvent.CLICK)
    function clickUnlock(_)
    {
        if (flashInvalidSession()) return;
        if (flashInvalidText(medalId)) return;
        send(NG.core.calls.medal.unlock(Std.parseInt(medalId.text)));
    }
    
    @:bind(getMedalScore, MouseEvent.CLICK)
    function clickGetMedalScore(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.medal.getMedalScore());
    }
}