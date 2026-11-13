package io.newgrounds.utils;

@:deprecated("AsyncNGCall has moved to ngio.net.AsyncHttp.AsyncNGCall")
typedef AsyncNGCall = ngio.net.AsyncHttp.AsyncNGCall;

@:deprecated("AsyncHttp has moved to ngio.net.AsyncHttp")
typedef AsyncHttp = ngio.net.AsyncHttp;

#if (target.threaded || neko || java || cpp)
@:deprecated("LoaderData has moved to ngio.net.AsyncHttp.LoaderData")
typedef LoaderData = ngio.net.AsyncHttp.LoaderData;

@:deprecated("ReplyData has moved to ngio.net.AsyncHttp.ReplyData")
typedef ReplyData = ngio.net.AsyncHttp.ReplyData;
#end
