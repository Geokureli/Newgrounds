package io.newgrounds.test;

import openfl.display.Sprite;
import openfl.display.Preloader;

class TestPreloader extends Preloader {
	
	public function new() {
		
		var sprite = new Sprite();
		sprite.graphics.beginFill(0xFF0000);
		sprite.graphics.drawRect(50, 50, 700, 700);
		sprite.graphics.endFill();
		
		super(sprite);
		
		onProgress.add(onUpdate);
	}
	
	public function onUpdate(bytesLoaded:Int, bytesTotal:Int):Void {
		
		// calculate the percent loaded
		var percentLoaded = bytesLoaded / bytesTotal;
		if (percentLoaded > 1)
			percentLoaded = 1;
	}
}
