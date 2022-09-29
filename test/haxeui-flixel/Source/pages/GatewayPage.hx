package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/gateway.xml"))
class GatewayPage extends Page
{
    @:bind(getDatetime, MouseEvent.CLICK)
    function clickGetDatetime(_) send(NG.core.calls.gateway.getDatetime());
    
    @:bind(getVersion, MouseEvent.CLICK)
    function clickGetVersion(_) send(NG.core.calls.gateway.getVersion());
    
    @:bind(ping, MouseEvent.CLICK)
    function clickPing(_) send(NG.core.calls.gateway.ping());
}
