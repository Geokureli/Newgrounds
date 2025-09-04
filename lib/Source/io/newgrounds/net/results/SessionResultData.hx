package io.newgrounds.net.results;
import io.newgrounds.net.data.Session;

typedef SessionResultData = BaseResultData & {
	
	var session(default, null):Session;
}