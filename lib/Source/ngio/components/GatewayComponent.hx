package ngio.components;

import ngio.net.Call;
import ngio.net.results.gateway.*;

class GatewayComponent extends Component
{
	public function getDatetime()
	{
		return (makeCall("Gateway.getDatetime"): Call<GetDateTimeResultData>);
	}
	
	public function getVersion()
	{
		return (makeCall("Gateway.getVersion"): Call<GetVersionResultData>);
	}
	
	public function ping()
	{
		return (makeCall("Gateway.ping"): Call<PingResultData>);
	}
}