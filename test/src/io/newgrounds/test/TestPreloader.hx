package io.newgrounds.test;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.ProgressEvent;

class TestPreloader extends Sprite {
	
	var _sprite:Sprite;
	
	public function new() {
		super();
		
		x += 50;
		graphics.beginFill(0xFF0000);
		graphics.drawRect(0, 350, 700, 50);
		graphics.endFill();
		
		addEventListener(Event.COMPLETE, onComplete);
		addEventListener(ProgressEvent.PROGRESS, onProgress);
	}
	
	function onProgress(e:ProgressEvent):Void {
		
		if (e.bytesTotal == 0)
			scaleX = 0;
		else if (e.bytesLoaded < e.bytesTotal)
			scaleX = e.bytesLoaded / e.bytesTotal;
		else
			scaleX = 1;
	}
	
	function onComplete(event:Event):Void {
		
		// event.preventDefault();
		// cast (event.currentTarget, Sprite).dispatchEvent(new Event(Event.UNLOAD));
	}
}