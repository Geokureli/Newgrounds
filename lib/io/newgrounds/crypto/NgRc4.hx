package io.newgrounds.crypto;

import io.newgrounds.NGLite.EncryptionFormat;

#if rc4
import haxe.crypto.Base64;
import haxe.io.Bytes;

import rc4.RC4;

class NgRc4 extends RC4 {
	
	var _format:EncryptionFormat;
	
	public function new(key:String, format:EncryptionFormat) {
		
		_format = format;
		
		var keyBytes:Bytes;
		if (_format == EncryptionFormat.BASE_64)
			keyBytes = Base64.decode(key);
		else
			keyBytes = null;//TODO
		
		super(keyBytes);
	}
	
	public function encrypt(data:String):String {
		
		var dataBytes = Bytes.ofString(data);
		
		dataBytes = crypt(dataBytes);
		
		if (_format == EncryptionFormat.BASE_64)
			return Base64.encode(dataBytes);
		//TODO
		return null;
	}
}
#else

class NgRc4 {
	
	static inline var ERROR:String = "rc4 is not available, install it using \"haxelib install rc4\" and add it to your project";
	
	public function new(key:String, format:EncryptionFormat) {
		
		throw ERROR;
	}
	
	public function encrypt(data:String):String { throw ERROR; }
}
#end