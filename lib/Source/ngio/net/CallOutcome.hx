package ngio.net;

import ngio.net.Error;
import ngio.net.Outcome;

typedef CallOutcome<T> = TypedOutcome<T, CallError>;

@:using(ngio.net.CallOutcome.CallErrorTools)
enum CallError
{
	/** There was an error sending the request or receiving the result. */
	HTTP(error:String);
	
	/** There was an error understanding the call. */
	RESPONSE(error:Error);
	
	/** There was an error executing the call. */
	RESULT(error:Error);
}

class CallErrorTools
{
	static public function toString(error:CallError)
	{
		return switch (error)
		{
			case HTTP(e): 'Http Error: $e';
			case RESPONSE(e): 'Response Error: $e';
			case RESULT(e): 'Result Error: $e';
		}
	}
}