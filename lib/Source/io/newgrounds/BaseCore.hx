package io.newgrounds;

import io.newgrounds.objects.AppData;
import io.newgrounds.utils.Logger;

class BaseCore {
	
	public final appData:AppData;
	
	public final logger:Logger;
	
	@:allow(io.newgrounds.components.Component)
	final callList = new CallList();
	
	/** The name of the host the game is being played on */
	public var host:Null<String>;
	
	/** 
	 * Iniitializes the API, call before utilizing any other component.
	 * 
	 * @param appId      The unique ID of your app as found in the 'API Tools' tab of your
	 *                   Newgrounds.com project.
	 * @param sessionId  A unique session id used to identify the active user.
	 * @param debug      Enables debug features and verbose responses from the server
	 * @param callback   If a sessionId was given, this will be called with the outcome of that
	 *                   login attempt.
	**/
	public function new(app:AppData, logPrefix:String) {
		
		appData = app;
		
		logger = new Logger((any, ?pos)->haxe.Log.trace('${logPrefix}${any}', pos));
	}
}