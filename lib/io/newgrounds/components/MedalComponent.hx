package io.newgrounds.components;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import io.newgrounds.Call;
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;

class MedalComponent extends Component {
	
	public var all      (default, null):Array<Medal>;
	public var allById  (default, null):IntMap<Medal>;
	public var allByName(default, null):StringMap<Medal>;
	
	public function new(core:NG):Void { super(core); }
	
	public function unlock(id:Int):Call {
		
		if (_core.assert(allById.exists(id), 'Cannot unlock medal, no id matches "$id"'))
			return allById.get(id).unlock();
		
		return null;
	}
	
	public function unlockByName(name:String):Call {
		
		if (_core.assert(allByName.exists(name), 'Cannot unlock medal, no name matches "$name"'))
			return allByName.get(name).unlock();
		
		return null;
	}
	
	public function getList():Call {
		
		return new Call(_core, "Medal.getList")
			.addDataHandler(onListReceived);
	}
	
	function onListReceived(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			return;
		}
		
		all = new Array<Medal>();
		allById = new IntMap<Medal>();
		allByName = new StringMap<Medal>();
		
		for (medalData in cast(data.data.medals, Array<Dynamic>)) {
			
			var medal = new Medal(_core, medalData);
			all.push(medal);
			allById.set(medal.id, medal);
			allByName.set(medal.name, medal);
		}
		
		_core.log('${all.length} Medals loaded');
	}
}