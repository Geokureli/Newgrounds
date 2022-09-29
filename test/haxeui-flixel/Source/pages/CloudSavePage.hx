package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/cloudsaves.xml"))
class CloudSavePage extends Page
{
    @:bind(loadSlots, MouseEvent.CLICK)
    function clickLoadSlots(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.cloudSave.loadSlots());
    }
    
    @:bind(loadSlot, MouseEvent.CLICK)
    function clickLoadSlot(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.cloudSave.loadSlot(Std.int(loadId.pos)));
    }
    
    @:bind(clearSlot, MouseEvent.CLICK)
    function clickClearSlot(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.cloudSave.clearSlot(Std.int(clearId.pos)));
    }
    
    @:bind(setData, MouseEvent.CLICK)
    function clickSetData(_)
    {
        if (flashInvalidSession()) return;
        send(NG.core.calls.cloudSave.setData(saveData.text, Std.int(setId.pos)));
    }
}