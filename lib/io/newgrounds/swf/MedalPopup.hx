package io.newgrounds.swf;

import io.newgrounds.objects.Medal;

import openfl.display.Loader;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.display.MovieClip;

class MedalPopup extends MovieClip {
    
    static inline var FRAME_HIDDEN:String = "hidden";
    static inline var FRAME_MEDAL_UNLOCKED:String = "medalUnlocked";
    
    public var medalIcon(default, null):MovieClip;
    
    var _animQueue:Array<Medal>;
    
    public function new() {
        super();
        
        if (stage != null)
            onAdded(null);
        else
            addEventListener(Event.ADDED_TO_STAGE, onAdded);
        
        gotoAndStop(FRAME_HIDDEN);
        addFrameScript(totalFrames, onUnlockAnimComplete);
    }
    
    function onAdded(e:Event):Void{
        
        if (NG.core.medals != null)
            onMedalsLoaded();
        else
            NG.core.onLogin.addOnce(NG.core.requestMedals.bind(onMedalsLoaded));
    }
    
    function onMedalsLoaded():Void {
        
        for (medal in NG.core.medals)
            medal.onUnlock.addOnce(onMedalOnlock.bind(medal));
    }
    
    function onMedalOnlock(medal:Medal):Void {
        
        _animQueue.push(medal);
        
        if (currentLabel == FRAME_HIDDEN)
            showNextAnim();
    }
    
    function showNextAnim():Void{
        
        visible = true;
        gotoAndPlay(FRAME_MEDAL_UNLOCKED);
        
        var loader = new Loader();
        medalIcon.addChild(loader);
        loader.load(new URLRequest(_animQueue.shift().icon));
    }
    
    function onUnlockAnimComplete():Void {
        
        medalIcon.removeChildAt(0);
        
        if (_animQueue.length == 0)
            hide();
        else 
            showNextAnim();
    }
    
    function hide():Void {
        
        visible = false;
        gotoAndStop(FRAME_HIDDEN);
    }
}
