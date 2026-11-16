package ngio.net.results;

import ngio.net.Error;

typedef BaseResultData =
{
	final success:Bool;
	final debug  :Null<Bool>;
	final error  :Null<Error>;
}