package io.newgrounds.components;

import io.newgrounds.objects.Session;
import io.newgrounds.NG;

class AppComponent extends Component {
	
	public var session(default, null):Session;
	public var sessionId(get, never):String;
	
	public function new (core:NG) { super(core); }
	
	public function startSession():Call {
		
		return new Call(_core, "App.startSession")
			.addDataHandler(onSessionUpdate);
	}
	
	public function checkSession():Call {
		
		return new Call(_core, "App.checkSession", true)
			.addDataHandler(onSessionUpdate);
	}
	
	function onSessionUpdate(data:Dynamic):Void {
		
		if (!data.data.success) {
			
			_core.logError('${data.component} - #${data.data.error.code}: ${data.data.error.message}');
			
			if (data.data.error.code == 111)
				session.expire();
			
			return;
		}
		
		session = new Session(_core, data.data.session);
	}
	
	public function endSession():Call {
		
		return new Call(_core, "App.endSession", true)
			.addDataHandler(onSessionEnd);
	}
	
	function onSessionEnd(data:Dynamic):Void {
		
		session = null;
	}
	
	public function getCurrentVersion(version:String):Call {
	
		return new Call(_core, "App.getCurrentVersion")
			.addComponentParameter("version", version);
	}
	
	public function getHostLicense(host:String):Call {
		
		return new Call(_core, "App.getHostLicense")
			.addComponentParameter("host", host);
	}
	
	public function logView(host:String):Call {
	
		return new Call(_core, "App.logView")
			.addComponentParameter("host", host);
	}
	
	public function get_sessionId():String {
		
		if (session != null && session.id != null && session.id != "")
			return session.id;
		
		return null;
	}
}