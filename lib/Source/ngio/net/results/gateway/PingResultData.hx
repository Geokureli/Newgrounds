package ngio.net.results.gateway;

import ngio.net.results.BaseResultData;

typedef PingResultData = BaseResultData &
{
	/** Will always have a value of 'pong'. */
	final pong:String;
}