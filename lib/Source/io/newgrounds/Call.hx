package io.newgrounds;

@:deprecated("io.newgrounds.Call is deprecated, use io.newgrounds.net.Call, instead")
typedef Call = io.newgrounds.net.Call;

@:deprecated("io.newgrounds.Call.ICallable is deprecated, use io.newgrounds.net.Call.ICallable, instead")
typedef ICallable = io.newgrounds.net.Call.ICallable;

@:deprecated("io.newgrounds.Call.CallOutcome is deprecated, use io.newgrounds.net.outcomes.CallOutcome, instead")
typedef CallOutcome<T> = io.newgrounds.net.outcomes.CallOutcome;

@:deprecated("io.newgrounds.Call.CallError is deprecated, use io.newgrounds.net.outcomes.CallOutcome.CallError, instead")
typedef CallError = io.newgrounds.net.outcomes.CallOutcome.CallError;

@:deprecated("io.newgrounds.Call.CallErrorTools is deprecated, use io.newgrounds.net.outcomes.CallOutcome.CallErrorTools, instead")
typedef CallErrorTools = io.newgrounds.net.outcomes.CallOutcome.CallErrorTools;
