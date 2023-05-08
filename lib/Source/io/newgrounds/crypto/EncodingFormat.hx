package io.newgrounds.crypto;

import haxe.io.Bytes;
import haxe.crypto.Base64;

#if haxe4 enum #else @:enum #end
abstract EncodingFormat(String) to String {
	var BASE_64 = "base64";
	var HEX     = "hex";
	
	public function encode(dataBytes:Bytes) {
		
		return switch(this) {
			
			case BASE_64: Base64.encode(dataBytes);
			case HEX    : dataBytes.toHex();
			default     : null;
		}
	}
	
	public function decode(data:String) {
		
		return switch(this) {
			
			case BASE_64: Base64.decode(data);
			case HEX    : Bytes.ofHex(data);
			default     : null;
		}
	}
}