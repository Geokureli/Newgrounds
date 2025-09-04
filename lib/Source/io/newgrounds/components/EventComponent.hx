package io.newgrounds.components;

import io.newgrounds.net.Call;
import io.newgrounds.net.results.event.*;

class EventComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function logEvent(eventName:String) {
		
		return (makeCall("Event.logEvent"): Call<LogEventResultData>)
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", core.host);
	}
}