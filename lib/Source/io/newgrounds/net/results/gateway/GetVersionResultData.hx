package io.newgrounds.net.results.gateway;

import io.newgrounds.net.data.Version;
import io.newgrounds.net.results.BaseResultData;

typedef GetVersionResultData = BaseResultData & {
	
	/** The version number (in X.Y.Z format). */
	final version:VersionString;
}