package io.newgrounds.components.gateway;

import io.newgrounds.objects.events.BaseResultData;

typedef PingData = BaseResultData & {
	
	/** Will always have a value of 'pong'. */
	final pong:String;
}