package io.newgrounds.components;

import io.newgrounds.NG;

class EventComponent extends Component {
	
	public function new (core:NG){ super(core); }
	
	public function logEvent(eventName:String, host:String):Call {
		
		return new Call(_core, "Event.logEvent")
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", host);
	}
}