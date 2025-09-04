package io.newgrounds.net.outcomes;

import io.newgrounds.net.outcomes.CallOutcome;

typedef LoginOutcome = Outcome<LoginFail>;

enum LoginFail
{
	/** The login was aborted. */
	CANCELLED(type:LoginCancel);
	
	/** The login attempt failed, somewhere. */
	ERROR(error:CallError);
}

enum LoginCancel
{
	/** The login was cancelled in the passport web page. */
	PASSPORT;
	
	/** The session was abandoned in this app. */
	MANUAL;
}
