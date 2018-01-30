package io.newgrounds.components;

import io.newgrounds.Call;
import io.newgrounds.NGLite;

class MedalComponent extends Component {
	
	public function new(core:NGLite):Void { super(core); }
	
	public function unlock(id:Int):Call {
		
		return new Call(_core, "Medal.unlock", true, true);
	}
	
	public function getList():Call {
		
		return new Call(_core, "Medal.getList");
	}
}