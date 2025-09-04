package io.newgrounds.components.gateway;

class GatewayComponent extends Component {
	
	public function new (core){ super(core); }
	
	public function getDatetime():Call<GetDateTimeData> {
		
		return makeCall("Gateway.getDatetime");
	}
	
	public function getVersion():Call<GetVersionData> {
		
		return makeCall("Gateway.getVersion");
	}
	
	public function ping():Call<PingData> {
		
		return makeCall("Gateway.ping");
	}
}