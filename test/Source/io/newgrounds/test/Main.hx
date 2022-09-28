package io.newgrounds.test;

#if !simple
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;
import io.newgrounds.test.art.IntroScreenSwf;
import io.newgrounds.test.ui.IntroPage;
import io.newgrounds.test.ui.MainScreen;
#end

class Main extends openfl.display.Sprite {
	
	public function new() {
		super();
		
		#if simple
		// A barebones test with no flashy UI
		new SimpleTest();
		#else
		// A flashy UI to showcase all the features
		var page = new IntroScreenSwf();
		addChild(page);
		
		new IntroPage(page,
			function onStart
			( appId        :String
			, sessionId    :String
			, debug        :Bool
			, encryptionKey:String
			, cipher       :Cipher
			, format       :EncodingFormat
			) {
				
				removeChild(page);
				page = null;
				
				addChild(new MainScreen(appId, sessionId, debug, encryptionKey, cipher, format));
			}
		);
		#end
	}
}