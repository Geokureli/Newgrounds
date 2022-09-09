package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class EventComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function logEvent(eventName:String):Call<LogEventData> {
		
		return new Call<LogEventData>(_core, "Event.logEvent")
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", _core.host);
	}
}