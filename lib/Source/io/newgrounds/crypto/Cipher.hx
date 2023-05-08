package io.newgrounds.crypto;

import haxe.io.Bytes;

#if haxe4 enum #else @:enum #end
abstract Cipher(String) to String{
	var NONE    = "none";
	var AES_128 = "aes128";
	var RC4     = "rc4";
	
	@:allow(io.newgrounds.NGLite)
	function generateEncrypter(key:Bytes):(Bytes)->Bytes {
		
		#if (ng_test_decryption || ng_test_decryption_verbose)
		// Advanced testing to make sure encryption/decryption is working
		return generateEncrypterAndTestDecrypter(key);
		#else
		return switch (this) {
			
			case RC4    : new Rc4(key).crypt;
			case AES_128: new Aes(key).encrypt;
			default     : null;
		}
		#end
	}
	
	function generateEncrypterAndTestDecrypter(key:Bytes):(Bytes)->Bytes {
		
		var encrypter:(Bytes)->Bytes;
		var decrypter:(Bytes)->Bytes;
		
		switch (this) {
			
			case RC4    : throw "Rc4 decryption not implemented";
			case AES_128:
				var aes = new Aes(key);
				encrypter = aes.encrypt;
				decrypter = aes.decrypt;
			default:
				return null;
		}
		
		return function (bytes) {
			
			// encrypt as usual
			var encrypted = encrypter(bytes);
			// decrypt the result
			var decrypted = decrypter(encrypted);
			// make sure it matches the source
			for (i in 0...bytes.length) {
				
				if (bytes.get(i) != decrypted.get(i))
					throw 'Reverse decryption did not match input, '
						+ 'expected:${bytes.toString()}, got:${decrypted.toString()}';
			}
			
			#if ng_test_decryption_verbose
			trace('Reverse decryption successful! ${bytes.toString()}');
			#end
			
			// return the result
			return encrypted;
		}
	}
}