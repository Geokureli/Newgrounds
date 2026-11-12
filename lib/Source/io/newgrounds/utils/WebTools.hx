package io.newgrounds.utils;

import haxe.DynamicAccess;

/**
 * Handy tools for js and flash targets to read vars from the browser, if available
 */
@:nullSafety(Strict)
class WebTools {
	
	public function new() {}
	
	/** Get the current URL */
	public function getUrl() {
		
		#if js
			return js.Browser.document.location.href;
		#elseif flash
			final info = flash.Lib.current.stage.loaderInfo;
			return info != null ? info.url : null;
		#else
			throw "getUrl not implemented";
		#end
	}
	
	/** Look for a NG.io session ID, if available */
	public function getSessionId():Null<String> {
		
		#if js
			
			final url = getUrl();
			
			// Check for URL params
			final index = url.indexOf("?");
			if (index != -1) {
				
				// Check for session ID in params
				for (param in url.substr(index + 1).split("&")) {
					
					final index = param.indexOf("=");
					if (index != -1 && param.substr(0, index) == "ngio_session_id")
						return param.substr(index + 1);
				}
			}
			
			return null;
			
		#elseif flash
			
			if (flash.Lib.current.stage.loaderInfo == null)
				return null;
			
			final params:DynamicAccess<String> = flash.Lib.current.stage.loaderInfo.parameters;
			if (params.exists("ngio_session_id"))
				return params.get("ngio_session_id");
			
			return null;
		#end
		
		throw "getSessionId not implemented";
		
		// --- EXAMPLE LOADER PARAMS
		//{ "1517703669"                : ""
		//, "ng_username"               : "GeoKureli"
		//, "NewgroundsAPI_SessionID"   : "F1LusbG6P8Qf91w7zeUE37c1752563f366688ac6153996d12eeb111a2f60w2xn"
		//, "NewgroundsAPI_PublisherID" : 1
		//, "NewgroundsAPI_UserID"      : 488329
		//, "NewgroundsAPI_SandboxID"   : "5a76520e4ae1e"
		//, "ngio_session_id"           : "0c6c4e02567a5116734ba1a0cd841dac28a42e79302290"
		//, "NewgroundsAPI_UserName"    : "GeoKureli"
		//}
	}
}