package io.newgrounds.net.results.gateway;

import io.newgrounds.net.results.BaseResultData;

typedef PingResultData = BaseResultData & {
	
	/** Will always have a value of 'pong'. */
	final pong:String;
}