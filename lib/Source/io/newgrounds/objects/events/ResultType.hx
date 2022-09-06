package io.newgrounds.objects.events;

// TODO: add error type to both enums

/**
 * Whether some action was successful and what the resulting value was,
 * or, if not, what error occured.
**/
enum TypedResultType<T>
{
	// TODO: UPPER CASE
	Error(error:String);
	Success(value:T);
}

/**
 * Whether some action was successful, or, if not, what error occured.
**/
enum ResultType
{
	// TODO: UPPER CASE
	Error(error:String);
	Success;
}