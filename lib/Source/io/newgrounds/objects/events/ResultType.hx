package io.newgrounds.objects.events;

/**
 * Whether some action was successful and what the resulting value was,
 * or, if not, what error occured.
**/
@:using(io.newgrounds.objects.events.ResultType.TypedResultTools)
enum TypedResultType<T, E>
{
	SUCCESS(value:T);
	FAIL(error:E);
}

class TypedResultTools
{
	inline static public function splitHandlerValues<T, E>
	( result  :TypedResultType<T, E>
	, ?success:(T)->Void
	, ?fail   :(E)->Void
	) {
		switch result
		{
			case SUCCESS(value) if (success != null): success(value);
			case FAIL   (error) if (fail    != null): fail   (error);
			default:
		}
	}
	
	inline static public function splitHandlers<T, E>
	( result  :TypedResultType<T, E>
	, ?success:(TypedResultType<T, E>)->Void
	, ?fail   :(TypedResultType<T, E>)->Void
	) {
		switch result
		{
			case SUCCESS(value) if (success != null): success(result);
			case FAIL   (error) if (fail    != null): fail   (result);
			default:
		}
	}
	
	inline static public function successHandler<T, E>
	( result :TypedResultType<T, E>
	, success:(T)->Void
	) {
		switch result
		{
			case FAIL(_): // nothing
			case SUCCESS(value): success(value);
		}
	}
	
	inline static public function assertSuccessHandler<T, E>
	( result :TypedResultType<T, E>
	, success:(T)->Void
	) {
		switch result
		{
			case SUCCESS(value): success(value);
			case FAIL   (error): throw error;
		}
	}
}

/**
 * Whether some action was successful, or, if not, what error occured.
**/
@:using(io.newgrounds.objects.events.ResultType.ResultTools)
enum ResultType<E>
{
	SUCCESS;
	FAIL(error:E);
}

class ResultTools
{
	/**
	 * Calls the list of function via daisy-chaining callbacks starting with the first. If any
	 * function fails, the callback is called with that Error, if all succeed, the callback is
	 * called with SUCCESS.
	 * 
	 * @param callback  The callback that handles the result of the chain.
	 * @param list      The functions in the order they should be called.
	 */
	static public function chain<E>
	( callback:(ResultType<E>)->Void
	, list:Array<((ResultType<E>)->Void)->Void>
	) {
		final initialCallback = callback;
		var i = list.length;
		while (i-- > 1)
		{
			final prevCallback = callback;
			final successHandler = list[i];
			callback = (r)->switch(r)
			{
				case SUCCESS: successHandler(prevCallback);
				case FAIL(_): initialCallback(r);
			}
		}
		list[0](callback);
	}
	
	// TODO: docs
	inline static public function splitHandlerValues<E>
	( result  :ResultType<E>
	, ?success:()->Void
	, ?fail   :(E)->Void
	) {
		switch result
		{
			case SUCCESS     if (success != null): success();
			case FAIL(error) if (fail    != null): fail   (error);
			default:
		}
	}
	
	inline static public function splitHandlers<E>
	( result  :ResultType<E>
	, ?success:(ResultType<E>)->Void
	, ?fail   :(ResultType<E>)->Void
	) {
		switch result
		{
			case SUCCESS     if (success != null): success(result);
			case FAIL(error) if (fail    != null): fail   (result);
			default:
		}
	}
	
	inline static public function successHandler<E>
	( result :ResultType<E>
	, success:()->Void
	) {
		switch result
		{
			case FAIL(_): // nothing
			case SUCCESS: success();
		}
	}
	
	inline static public function assertSuccessHandler<E>
	( result :ResultType<E>
	, success:()->Void
	) {
		switch result
		{
			case SUCCESS: success();
			case FAIL(error): throw error;
		}
	}
}
