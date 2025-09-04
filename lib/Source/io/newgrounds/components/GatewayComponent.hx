package io.newgrounds.components;

import io.newgrounds.net.Call;
import io.newgrounds.net.results.gateway.*;

class GatewayComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function getDatetime() {
		
		return (makeCall("Gateway.getDatetime"): Call<GetDateTimeResultData>);
	}
	
	public function getVersion() {
		
		return (makeCall("Gateway.getVersion"): Call<GetVersionResultData>);
	}
	
	public function ping() {
		
		return (makeCall("Gateway.ping"): Call<PingResultData>);
	}
}