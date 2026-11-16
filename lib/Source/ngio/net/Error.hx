package ngio.net;

@:noCompletion
typedef RawErrorData =
{
	final message:String;
	final ?code  :Int;
}

abstract Error(RawErrorData) from RawErrorData
{
	inline public function toString():String
	{
		return (this.code != null ? '#${this.code}} - ' : "") + this.message;
	}
}
