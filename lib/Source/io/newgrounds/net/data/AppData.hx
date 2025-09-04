package io.newgrounds.net.data;

import io.newgrounds.crypto.Encryption;

@:structInit
class AppData
{
	/**
	 * The unique ID of your app as found in the 'API Tools' tab of your Newgrounds.com project.
	 */
	public final id:String;
	
	/**
	 * The encryption to use when sending sensitive data to the server. It's recommended to use
	 * `AES_128(myEncryptionKey)` which uses base 64 encoding and a aes128 encryption (the default
	 * settings in the Newgrounds project manager). To use a custom encryption, use `FUNC(myEncrypter)`
	 * 
	 * Defaults to `NONE`
	 */
	public var encryption:Encryption = NONE;
	
	/**
	 * Enables debug features and verbose responses from the server, defaults
	 */
	public var debug:Bool = false;
	
	/**
	 * A unique session id used to identify the active user.
	 */
	public var sessionId:Null<String> = null;
}