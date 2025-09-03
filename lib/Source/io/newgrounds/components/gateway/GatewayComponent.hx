package io.newgrounds.components.gateway;

class GatewayComponent extends Component {
	
	public function new (core){ super(core); }
	
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