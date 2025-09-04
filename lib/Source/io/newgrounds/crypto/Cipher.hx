package io.newgrounds.crypto;

import haxe.io.Bytes;

@:using(io.newgrounds.crypto.Cipher.CipherTools)
enum Cipher {
	
	NONE;
	AES_128;
	RC4;
}

class CipherTools {
	
	static public function toString(cipher:Cipher) {
		
		return switch cipher {
			case AES_128: "aes128";
			case RC4    : "rc4";
			case NONE   : "none";
		}
	}
	
	static public function fromString(cipher:String) {
		
		return switch cipher {
			case "aes128": AES_128;
			case "rc4"   : RC4;
			case "none"  : NONE;
			case invalid:
				throw 'Invalid cipher: $invalid';
		}
	}
	
	static public function generateEncrypter(cipher:Cipher, key:Bytes):Null<(Bytes)->Bytes> {
		
		#if (ng_test_decryption || ng_test_decryption_verbose)
		// Advanced testing to make sure encryption/decryption is working
		return generateEncrypterAndTestDecrypter(key);
		#else
		return switch (cipher) {
			
			case RC4    : new Rc4(key).crypt;
			case AES_128: new Aes(key).encrypt;
			default     : null;
		}
		#end
	}
	
	function generateEncrypterAndTestDecrypter(cipher:Cipher, key:Bytes):Null<(Bytes)->Bytes> {
		
		var encrypter:(Bytes)->Bytes;
		var decrypter:(Bytes)->Bytes;
		
		switch (cipher) {
			
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