package io.newgrounds;

@:deprecated("Call has moved to ngio.net.Call")
typedef Call<T:ngio.net.results.BaseResultData> = ngio.net.Call<T>;

@:deprecated("ICallable has moved to ngio.net.Call.ICallable")
typedef ICallable = ngio.net.Call.ICallable;

@:deprecated("CallOutcome has moved to ngio.net.CallOutcome")
typedef CallOutcome<T> = ngio.net.CallOutcome<T>;

@:deprecated("CallError has moved to ngio.net.CallOutcome.CallError")
typedef CallError = ngio.net.CallOutcome.CallError;

@:deprecated("CallErrorTools has moved to ngio.net.CallOutcome.CallErrorTools")
typedef CallErrorTools = ngio.net.CallOutcome.CallErrorTools;
