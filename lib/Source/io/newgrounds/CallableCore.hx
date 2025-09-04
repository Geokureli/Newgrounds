package io.newgrounds;

import io.newgrounds.components.ComponentList;

class CallableCore extends BaseCore {
	
	/** Components used to call the NG server directly */
	public final calls:ComponentList;
	
	public function new(app, logger) {
		
		super(app, logger);
		
		calls = new ComponentList(this);
	}
}