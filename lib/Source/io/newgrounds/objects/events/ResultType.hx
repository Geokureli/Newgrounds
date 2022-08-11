package io.newgrounds.objects.events;

/**
 * Whether some action was successful and what the resulting value was,
 * or, if not, what error occured.
**/
enum TypedResultType<T>
{
	Error(error:String);
	Success(value:T);
}

/**
 * Whether some action was successful, or, if not, what error occured.
**/
enum ResultType
{
	Error(error:String);
	Success;
}