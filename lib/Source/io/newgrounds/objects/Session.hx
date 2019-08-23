package io.newgrounds.objects;

@:noCompletion
typedef RawSessionData = {
	
	var id          (default, never):String;
	var expired     (default, never):Bool;
	var passport_url(default, never):String;
	var remember    (default, never):Bool;
	var user        (default, never):User;
}

abstract Session(RawSessionData) from RawSessionData {
	
	/** If true, the session_id is expired. Use App.startSession to get a new one.*/
	public var expired(get, never):Bool;
	public function get_expired() return this.expired;
	
	/** A unique session identifier */
	public var id(get, never):String;
	public function get_id() return this.id;
	
	/** If the session has no associated user but is not expired, this property will provide a URL that can be used to sign the user in. */
	public var passportUrl(get, never):String;
	public function get_passportUrl() return this.passport_url;
	
	/** If true, the user would like you to remember their session id. */
	public var remember(get, never):Bool;
	public function get_remember() return this.remember;
	
	/** If the user has not signed in, or granted access to your app, this will be null */
	public var user(get, never):User;
	public function get_user() return this.user;
	
	//TODO:desciption
	public var status(get, never):SessionStatus;
	
	public function get_status():SessionStatus {
		
		if (this.expired || this.id == null || this.id == "")
			return SessionStatus.SESSION_EXPIRED;
		
		if (this.user != null && this.user.name != null && this.user.name != "")
			return SessionStatus.USER_LOADED;
		
		return SessionStatus.REQUEST_LOGIN;
	}
}

@:enum
abstract SessionStatus(String) {
	
	var SESSION_EXPIRED = "session-expired";
	var REQUEST_LOGIN   = "request-login";
	var USER_LOADED     = "user-loaded";
}