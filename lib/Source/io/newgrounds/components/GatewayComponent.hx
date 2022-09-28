package io.newgrounds.components;

import io.newgrounds.objects.events.Result;
import io.newgrounds.NGLite;

class GatewayComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	public function getDatetime():Call<GetDateTimeData> {
		
		return new Call<GetDateTimeData>(_core, "Gateway.getDatetime");
	}
	
	public function getVersion():Call<GetVersionData> {
		
		return new Call<GetVersionData>(_core, "Gateway.getVersion");
	}
	
	public function ping():Call<PingData> {
		
		return new Call<PingData>(_core, "Gateway.ping");
	}
}