package io.newgrounds.utils;

import io.newgrounds.Call;
import io.newgrounds.NG;
import io.newgrounds.NGLite;
import io.newgrounds.objects.Session;
import io.newgrounds.objects.events.Outcome;
import io.newgrounds.objects.events.Result;

/**
 * 
 * @author GeoKureli
 */
@:allow(io.newgrounds.NG)
@:access(io.newgrounds.NG)
class SessionUtil {
	
	/** The session id found in url params */
	public final initialId:Null<String>;
	
	/** Called whenever the api connects to an active session */
	public final onLogIn:Dispatcher;
	/** Called whenever the api disconnects from the active session */
	public final onLogOut:Dispatcher;
	
	/** The session status of the api */
	public var status:LoginStatus = LOGGED_OUT;
	
	/** The current active session, if logged in */
	public var current(get, never):Session;
	inline function get_current():Session {
		
		return switch(status) {
			
			case LOGGED_IN(session): session;
			default: null;
		}
	}
	
	final _core:NG;
	
	public function new(core:NG) {
		
		_core = core;
		initialId = NGLite.getSessionId();
		onLogIn = new Dispatcher();
		onLogOut = new Dispatcher();
	}
	
	/**
	 * Tries to login any way it can. It first tries to connect to the `initialId` if any, if
	 * there is no initial session or if it is expires it will start a new session.
	 * 
	 * @param   callback         Receives the result of the login attempt
	 * @param   passportHandler  Called once the passport url is known, if `null`, the url is opened
	 *                           automatically. **Note:** some browsers have restrictions where
	 *                           urls must be opened via user input, such as a mouse click or
	 *                           keyboard event.
	 */
	public function autoConnect(callback:(LoginOutcome)->Void, ?passportHandler:(String)->Void) {
		
		if (initialId != null) {
			
			function onConnectOutcome (outcome:SessionCheckOutcome) {
				
				switch outcome {
					
					case SUCCESS(_): callback(SUCCESS);
					case FAIL(CALL(error)): callback(FAIL(ERROR(error)));
					case FAIL(CANCELLED(type)): callback(FAIL(CANCELLED(type)));
					case FAIL(EXPIRED):
						startNew(callback, passportHandler);
				}
			}
			
			connectTo(initialId, onConnectOutcome, passportHandler);
			
		} else {
			
			startNew(callback, passportHandler);
		}
	}
	
	/**
	 * Checks the status of the supplied session id, if the session is active, it will connect
	 * 
	 * @param   sessionId        The id of session to connect to
	 * @param   callback         Receives the result of the login attempt
	 * @param   passportHandler  Called once the passport url is known, if `null`, the url is opened
	 *                           automatically. **Note:** some browsers have restrictions where
	 *                           urls must be opened via user input, such as a mouse click or
	 *                           keyboard event.
	 */
	public function connectTo(sessionId:String, callback:(SessionCheckOutcome)->Void, ?passportHandler:(String)->Void) {
		
		switch (status) {
			
			case LOGGED_IN(_):
				throw 'Cannot check session id while in another session. Log out, first';
			case AWAITING_PASSPORT(_):
				throw 'Cannot check session id while attemping to start a new session. Cancel the current passport, first';
			case STARTING_NEW:
				throw 'Cannot check session id while attemping to start a new session. Cancel login, first';
			case CHECKING_STATUS(oldId) if (oldId == sessionId):
				throw 'Already checking session: $oldId, wait before checking again';
			case CHECKING_STATUS(oldId):
				throw 'Already checking session: $oldId, wait before checking new session: $sessionId';
			case LOGGED_OUT:
				// no problemo
		}
		
		status = CHECKING_STATUS(sessionId);
		
		_core.calls.app.checkSession(sessionId)
			.addOutcomeHandler((outcome)->{
				
				// check if cancelled
				if (isCheckingStatus(sessionId) == false)
				{
					callback(FAIL(CANCELLED(MANUAL)));
					return;
				}
				
				onSessionCheckOutcome(outcome, callback, passportHandler);
			})
			.send();
	}
	
	function isCheckingStatus(sessionId:String) {
		
		return switch status {
			
			case CHECKING_STATUS(id) if (id == sessionId): true;
			default: false;
		}
	}
	
	function isAwaitingPassport(session:Session) {
		
		return switch status {
			
			case AWAITING_PASSPORT(s) if (s.id == session.id): true;
			default: false;
		}
	}
	
	function onSessionCheckOutcome(outcome:CallOutcome<SessionData>, callback:(SessionCheckOutcome)->Void, ?passportHandler:(String)->Void)
	{
		switch outcome {
			
			case SUCCESS(data):
				
				switch (data.session.status) {
					
					case SESSION_EXPIRED:
						
						status = LOGGED_OUT;
						callback(FAIL(EXPIRED));
						
					case REQUEST_LOGIN:
						
						handlePassport(data.session, passportHandler, (outcome)->switch outcome {
							case SUCCESS(session):
								
								onSessionConnect(session);
								callback(SUCCESS(session));
								
							case FAIL(error):
								
								status = LOGGED_OUT;
								callback(FAIL(error));
						});
						
					case USER_LOADED:
						
						onSessionConnect(data.session);
						callback(SUCCESS(data.session));
				}
				
			case FAIL(error):
				
				status = LOGGED_OUT;
				callback(FAIL(CALL(error)));
		}
	}
	
	function onSessionConnect(session:Session) {
		
		status = LOGGED_IN(session);
		onLogIn.dispatch();
	}
	
	function handlePassport(session:Session, ?handler:(String)->Void, callback:(SessionCheckOutcome)->Void) {
		
		status = AWAITING_PASSPORT(session);
		if (handler != null)
			handler(session.passportUrl);
		else
			_core.openUrl(session.passportUrl);
		
		waitForPassport(session, callback);
	}
	
	function waitForPassport(session:Session, callback:(SessionCheckOutcome)->Void) {
		
		timer(1.0, ()->{
			// check if cancelled
			final status = status;
			if (isAwaitingPassport(session) == false) {
				
				callback(FAIL(CANCELLED(MANUAL)));
				return;
			}
			
			_core.calls.app.checkSession(session.id)
				.addOutcomeHandler((outcome)->{
					
					// check if cancelled, again
					if (isAwaitingPassport(session) == false) {
						
						callback(FAIL(CANCELLED(MANUAL)));
						return;
					}
					
					switch (outcome) {
						
						case SUCCESS(data):
							
							switch data.session.status {
								
								case SESSION_EXPIRED: callback(FAIL(CANCELLED(PASSPORT)));
								case REQUEST_LOGIN: waitForPassport(data.session, callback);
								case USER_LOADED: callback(SUCCESS(data.session));
							}
							
						case FAIL(error):
							callback(FAIL(CALL(error)));
					}
						// waitForPassport(session, callback);
				})
				.send();
			}
		);
	}
	
	function timer(delay:Float, callback:()->Void):Void {
		
		var timer = new haxe.Timer(Std.int(delay * 1000));
		timer.run = function func():Void {
			
			timer.stop();
			callback();
		}
	}
	
	/**
	 * Starts a new session
	 * 
	 * @param   callback         Receives the result of the login attempt
	 * @param   passportHandler  Called once the passport url is known, if `null`, the url is opened
	 *                           automatically. **Note:** some browsers have restrictions where
	 *                           urls must be opened via user input, such as a mouse click or
	 *                           keyboard event.
	 */
	public function startNew(callback:(LoginOutcome)->Void, ?passportHandler:(String)->Void) {
		
		switch (status) {
			
			case LOGGED_IN(_):
				throw 'Cannot log in while already logged in. Log out, first';
			case AWAITING_PASSPORT(_)
				| STARTING_NEW:
				throw 'Cannot log in while already attemping to start a new session. Cancel login, first';
			case CHECKING_STATUS(_):
				throw 'Cannot log in while checking a session status. Cancel, first';
			case LOGGED_OUT:
				// no problemo
		}
		
		status = STARTING_NEW;
		_core.calls.app.startSession(true)
			.addOutcomeHandler(
				function (outcome) {
					
					// check if cancelled
					if (status.match(STARTING_NEW) == false) {
						
						callback(FAIL(CANCELLED(MANUAL)));
						return;
					}
					
					final session = switch(outcome) {
						
						case SUCCESS(data): data.session;
						case FAIL(error):
							
							status = LOGGED_OUT;
							callback(FAIL(ERROR(error)));
							return;
					}
					
					_core.logVerbose('session started - status: ${session.status}');
					
					switch (session.status) {
						
						case SESSION_EXPIRED:
							
							status = LOGGED_OUT;
							callback(FAIL(CANCELLED(PASSPORT)));
							
						case USER_LOADED://should never happen, but ok lol
							
							onSessionConnect(session);
							callback(SUCCESS);
							
						case REQUEST_LOGIN:
							
							handlePassport(session, passportHandler, (outcome:SessionCheckOutcome)->switch outcome {
								
								case SUCCESS(connectedSession):
									
									onSessionConnect(connectedSession);
									callback(SUCCESS);
									
								case FAIL(CANCELLED(type)):
									
									status = LOGGED_OUT;
									callback(FAIL(CANCELLED(type)));
									
								case FAIL(EXPIRED):
									
									status = LOGGED_OUT;
									callback(FAIL(CANCELLED(PASSPORT)));
									
								case FAIL(CALL(error)):
									
									status = LOGGED_OUT;
									callback(FAIL(ERROR(error)));
							});
					}
				}
			)
			.send();
	}
	
	/**
	 * Logs out of the current session
	 * 
	 * @param   onComplete  Receives the result of the end session call
	 */
	public function endCurrent(?onComplete:(Outcome<CallError>)->Void) {
		
		switch (status) {
			
			case LOGGED_IN(_): // all good
			case CHECKING_STATUS(sessionId):
				throw 'Cannot end the current session until the session status is determinined. Cancel, first.';
			case LOGGED_OUT:
				throw 'Cannot end the current session if there is no session.';
			case STARTING_NEW:
				cancel();
			case AWAITING_PASSPORT(_):
				cancel();
		}
		
		function onSuccess() {
			
			status = LOGGED_OUT;
			onLogOut.dispatch();
		};
		
		var call = _core.calls.app.endSession()
			.addSuccessHandler(onSuccess);
		
		if (onComplete != null) {
			
			call.addOutcomeHandler((outcome)->switch outcome {
				
				case SUCCESS(_): onComplete(SUCCESS);
				case FAIL(error): onComplete(FAIL(error));
			});
		}
		
		call.send();
	}
	
	/**
	 * Cancels any current attempt to log in. Does not log out, if you're logged in
	 */
	public function cancel() {
		
		switch (status) {
			
			case CHECKING_STATUS(_)
				| STARTING_NEW
				| AWAITING_PASSPORT(_):
				
			case LOGGED_OUT:
				_core.logError('Attempting to cancel login when already logged out');
			case LOGGED_IN(_):
				_core.logError('To end the current session use endCurrent(), not cancel()');
		}
		
		status = LOGGED_OUT;
	}
	
	/**
	 * Cancelled any current attempt to log in. Does not log out, if you're logged in
	 */
	function getPassportUrl() {
		
		return switch (status) {
			
			case AWAITING_PASSPORT(session): session.passportUrl;
			case LOGGED_IN(session): session.passportUrl;
			default: null;
		}
	}
	
	/**
	 * Cancelled any current attempt to log in. Does not log out, if you're logged in
	 */
	public function openPassportUrl() {
		
		switch (status) {
			
			case AWAITING_PASSPORT(session):
				
				_core.openUrl(session.passportUrl);
				
			case LOGGED_IN(_):
				throw 'Cannot open the passport url when already logged in';
			case LOGGED_OUT:
				throw 'Cannot open the passport url while logged out';
			default:
				throw 'Cannot open the passport url';
		}
	}
}

enum LoginStatus {
	
	LOGGED_OUT;
	CHECKING_STATUS(sessionId:String);
	STARTING_NEW;
	AWAITING_PASSPORT(session:Session);
	LOGGED_IN(session:Session);
}

enum CheckSessionError
{
	CALL(error:CallError);
	CANCELLED(type:LoginCancel);
	EXPIRED;
}

typedef SessionCheckOutcome = TypedOutcome<Session, CheckSessionError>;