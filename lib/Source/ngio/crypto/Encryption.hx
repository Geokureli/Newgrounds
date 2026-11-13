package ngio.crypto;

import haxe.io.Bytes;
import ngio.crypto.Cipher.CipherTools;

@:using(ngio.crypto.Encryption.EncryptionTools)
enum Encryption
{
	FUNC(func:(String)->String);
	AES_128(key:String, ?format:EncodingFormat);
	RC4(key:String, ?format:EncodingFormat);
	NONE;
}

class EncryptionTools
{
	static final cache = new Map<String, (String)->String>();
	
	static public function encrypt(encryption:Encryption, data:String):String
	{
		return switch encryption
		{
			case NONE: data;
			case FUNC(func): func(data);
			case AES_128(key, null): getCached(Cipher.AES_128, key)(data);
			case AES_128(key, format): getCached(Cipher.AES_128, key, format)(data);
			case RC4(key, null): getCached(Cipher.RC4, key)(data);
			case RC4(key, format): getCached(Cipher.RC4, key, format)(data);
		}
	}
	
	static function getCached(cipher:Cipher, key:String, format = EncodingFormat.BASE_64)
	{
		final lookup = '$cipher-$key-$format';
		if (false == cache.exists(lookup))
		{
			final encrypt = cipher.generateEncrypter(format.decode(key));
			cache[lookup] = (data)->format.encode(encrypt(Bytes.ofString(data)));
		}
		
		return cache[lookup];
	}
	
	static public function create(cipher:Cipher, key:String, format = EncodingFormat.BASE_64):Encryption
	{
		return switch cipher
		{
			case Cipher.NONE: return Encryption.NONE;
			case Cipher.AES_128: return Encryption.AES_128(key, format);
			case Cipher.RC4: return Encryption.RC4(key, format);
		}
	}
	
	static public function fromString(cipher, key, format)
	{
		return create(CipherTools.fromString(cipher), key, EncodingFormat.fromString(format));
	}
}