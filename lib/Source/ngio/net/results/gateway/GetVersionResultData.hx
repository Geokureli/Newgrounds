package ngio.net.results.gateway;

import ngio.data.VersionData;
import ngio.net.results.BaseResultData;

typedef GetVersionResultData = BaseResultData &
{
	/** The version number (in X.Y.Z format). */
	final version:VersionData;
}