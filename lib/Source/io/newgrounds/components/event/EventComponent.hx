package io.newgrounds.components.event;

class EventComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function logEvent(eventName:String) {
		
		return (makeCall("Event.logEvent"): Call<LogEventData>)
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", core.host);
	}
}