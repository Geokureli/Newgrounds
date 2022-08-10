package io.newgrounds.objects.events;

enum TypedResultType<T>
{
	Error(error:String);
	Success(value:T);
}

enum ResultType
{
	Error(error:String);
	Success;
}