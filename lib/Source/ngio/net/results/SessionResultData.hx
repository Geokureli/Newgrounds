package ngio.net.results;
import ngio.data.SessionData;

typedef SessionResultData = BaseResultData &
{
	var session(default, null):SessionData;
}