package io.newgrounds.components.gateway;

import io.newgrounds.objects.Version;
import io.newgrounds.objects.events.BaseResultData;

typedef GetVersionData = BaseResultData & {
	
	/** The version number (in X.Y.Z format). */
	final version:VersionString;
}