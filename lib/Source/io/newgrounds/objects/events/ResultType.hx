package io.newgrounds.objects.events;

/**
 * Whether some action was successful and what the resulting value was,
 * or, if not, what error occured.
**/
enum TypedResultType<T, E>
{
	SUCCESS(value:T);
	FAIL(error:E);
}

/**
 * Whether some action was successful, or, if not, what error occured.
**/
enum ResultType<E>
{
	SUCCESS;
	FAIL(error:E);
}