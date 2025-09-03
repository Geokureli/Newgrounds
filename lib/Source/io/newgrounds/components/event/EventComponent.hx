package io.newgrounds.components.event;

class EventComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function logEvent(eventName:String):Call<LogEventData> {
		
		return new Call<LogEventData>(_core, "Event.logEvent")
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", _core.host);
	}
}