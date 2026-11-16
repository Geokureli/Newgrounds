package ngio.components;

import ngio.net.Call;
import ngio.net.results.event.*;

class EventComponent extends Component
{
	public function logEvent(eventName:String)
	{
		return (makeCall("Event.logEvent"): Call<LogEventResultData>)
			.addComponentParameter("event_name", eventName)
			.addComponentParameter("host", core.host);
	}
}