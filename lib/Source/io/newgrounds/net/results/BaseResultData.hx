package io.newgrounds.net.results;

import io.newgrounds.net.data.Error;

typedef BaseResultData = {
	
	final success:Bool;
	final debug  :Null<Bool>;
	final error  :Null<Error>;
}