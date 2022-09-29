package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/event.xml"))
class EventPage extends Page
{
    @:bind(logEvent, MouseEvent.CLICK)
    function clickLogEvent(_)
    {
        if (flashInvalidHost()) return;
        if (flashInvalidText(event)) return;
        send(NG.core.calls.event.logEvent(event.text));
    }
}