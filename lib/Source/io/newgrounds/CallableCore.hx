package io.newgrounds;

import io.newgrounds.components.ComponentList;

@:nullSafety(Strict)
class CallableCore extends BaseCore {
	
	/** Components used to call the NG server directly */
	public final calls:ComponentList;
	
	public function new(app, logger) {
		
		super(app, logger);
		
		calls = new ComponentList(this);
	}
}