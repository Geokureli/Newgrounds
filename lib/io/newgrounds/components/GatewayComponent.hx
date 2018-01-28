package io.newgrounds.components;

import io.newgrounds.NG;

class GatewayComponent extends Component {
	
	public function new (core:NG){ super(core); }
	
	public function getDatetime():Call {
		
		return new Call(_core, "Gateway.getDatetime");
	}
	
	public function getVersion():Call {
		
		return new Call(_core, "Gateway.getVersion");
	}
	
	public function ping():Call {
		
		return new Call(_core, "Gateway.ping");
	}
	
}