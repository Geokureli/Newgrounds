package io.newgrounds;

@:deprecated("Call has moved to ngio.net.Call")
typedef Call<T:BaseResultData> = ngio.net.Call<T>;

@:deprecated("ICallable has moved to ngio.net.Call.ICallable")
typedef ICallable = ngio.net.Call.ICallable;

@:deprecated("CallOutcome has moved to ngio.net.Call.CallOutcome")
typedef CallOutcome<T> = ngio.net.outcomes.CallOutcome<T>;

@:deprecated("CallError has moved to ngio.net.Call.CallError")
typedef CallError = ngio.net.outcomes.CallOutcome.CallError;

@:deprecated("CallErrorTools has moved to ngio.net.Call.CallErrorTools")
typedef CallErrorTools = ngio.net.outcomes.CallOutcome.CallErrorTools;
