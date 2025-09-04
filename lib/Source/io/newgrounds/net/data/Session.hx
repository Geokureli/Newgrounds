package io.newgrounds.net.data;

@:noCompletion
typedef RawSessionData = {
	
	/** A unique session identifier */
	final id          :String;
	
	/** If true, the session_id is expired. Use App.startSession to get a new one.*/
	final expired     :Bool;
	
	/** If the session has no associated user but is not expired, this property will provide a URL that can be used to sign the user in. */
	final passport_url:String;
	
	/** If true, the user would like you to remember their session id. */
	final remember    :Bool;
	
	/** If the user has not signed in, or granted access to your app, this will be null */
	final user        :User;
}

@:forward
abstract Session(RawSessionData) from RawSessionData {
	
	/** If the session has no associated user but is not expired, this property will provide a URL that can be used to sign the user in. */
	public var passportUrl(get, never):String;
	inline function get_passportUrl() return this.passport_url;
	var passport_url(get, never):String;
	inline function get_passport_url() return this.passport_url;
	
	//TODO:desciption
	public var status(get, never):SessionStatus;
	
	function get_status():SessionStatus {
		
		if (this.expired || this.id == null || this.id == "")
			return SessionStatus.SESSION_EXPIRED;
		
		if (this.user != null && this.user.name != null && this.user.name != "")
			return SessionStatus.USER_LOADED;
		
		return SessionStatus.REQUEST_LOGIN;
	}
}

enum abstract SessionStatus(String) {
	
	var SESSION_EXPIRED = "session-expired";
	var REQUEST_LOGIN   = "request-login";
	var USER_LOADED     = "user-loaded";
}