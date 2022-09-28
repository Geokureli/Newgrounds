package io.newgrounds.objects.events;

/**
 * Whether some action was successful and what the resulting value was,
 * or, if not, what error occured.
**/
@:using(io.newgrounds.objects.events.Outcome.TypedOutcomeTools)
enum TypedOutcome<T, E>
{
	SUCCESS(value:T);
	FAIL(error:E);
}

class TypedOutcomeTools
{
	/**
	 * Calls the callback if it's not null
	 */
	inline static public function safe<T, E>
	( callback:Null<(TypedOutcome<T, E>)->Void>
	, outcome:TypedOutcome<T, E>
	) {
		
		if (callback != null)
			callback(outcome);
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, depending on the supplied outcome.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	 * @param fail    Handler called if the outcome is a failure.
	**/
	inline static public function splitHandlerValues<T, E>
	( outcome :TypedOutcome<T, E>
	, ?success:(T)->Void
	, ?fail   :(E)->Void
	) {
		switch outcome {
			
			case SUCCESS(value) if (success != null): success(value);
			case FAIL   (error) if (fail    != null): fail   (error);
			default:
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome, depending on the supplied outcome.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	 * @param fail    Handler called if the outcome is a failure.
	**/
	inline static public function splitHandlers<T, E>
	( outcome :TypedOutcome<T, E>
	, ?success:(TypedOutcome<T, E>)->Void
	, ?fail   :(TypedOutcome<T, E>)->Void
	) {
		switch outcome {
			
			case SUCCESS(value) if (success != null): success(outcome);
			case FAIL   (error) if (fail    != null): fail(outcome);
			default:
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, if the outcome was successful.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	**/
	inline static public function successHandler<T, E>
	( outcome:TypedOutcome<T, E>
	, success:(T)->Void
	) {
		switch outcome {
			
			case FAIL(_): // nothing
			case SUCCESS(value): success(value);
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, if the outcome was successful.
	 * Otherwise, an error is thrown.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	**/
	inline static public function assertSuccessHandler<T, E>
	( outcome:TypedOutcome<T, E>
	, success:(T)->Void
	) {
		switch outcome {
			
			case SUCCESS(value): success(value);
			case FAIL   (error): throw error;
		}
	}
	
	/**
	 * Throws an error if the result is a failure.
	 * 
	 * @param outcome The outcome.
	**/
	inline static public function assert<T, E>(outcome:TypedOutcome<T, E>) {
		
		switch outcome {
			
			case FAIL(error): throw error;
			case SUCCESS(_): //nothing
		}
	}
	
	/**
	 * Converts the outcome from a `TypedOutcome<T, E>` to an `Outcome<E>` by ignoring the success
	 * value
	 * 
	 * @param outcome The outcome.
	**/
	inline static public function toUntyped<T, E>(outcome:TypedOutcome<T, E>):Outcome<E> {
		
		return switch outcome {
			
			case SUCCESS(_): SUCCESS;
			case FAIL(error): FAIL(error);
		}
	}
	
	inline static public function errorToString<T, E>(outcome:TypedOutcome<T, E>):TypedOutcome<T, String> {
		
		return switch(outcome) {
			
			case SUCCESS(value): SUCCESS(value);
			case FAIL(error): FAIL(Std.string(error));
		}
	}
}

/**
 * Whether some action was successful, or, if not, what error occured.
**/
@:using(io.newgrounds.objects.events.Outcome.OutcomeTools)
enum Outcome<E>
{
	SUCCESS;
	FAIL(error:E);
}

class OutcomeTools
{
	/**
	 * Calls the callback if it's not null
	 */
	inline static public function safe<E>(callback:Null<(Outcome<E>)->Void>, outcome:Outcome<E>) {
		
		if (callback != null)
			callback(outcome);
	}
	
	/**
	 * Calls the list of function via daisy-chaining callbacks starting with the first. If any
	 * function fails, the callback is called with that Error, if all succeed, the callback is
	 * called with SUCCESS.
	 * 
	 * @param callback  The callback that handles the outcome of the chain.
	 * @param list      The functions in the order they should be called.
	 */
	static public function chain<E>
	( callback:(Outcome<E>)->Void
	, list:Array<((Outcome<E>)->Void)->Void>
	) {
		final initialCallback = callback;
		var i = list.length;
		while (i-- > 1) {
			
			final prevCallback = callback;
			final successHandler = list[i];
			callback = (o)->switch(o) {
				
				case SUCCESS: successHandler(prevCallback);
				case FAIL(_): initialCallback(o);
			}
		}
		list[0](callback);
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, depending on the supplied outcome.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	 * @param fail    Handler called if the outcome is a failure.
	**/
	inline static public function splitHandlerValues<E>
	( outcome :Outcome<E>
	, ?success:()->Void
	, ?fail   :(E)->Void
	) {
		switch outcome {
			
			case SUCCESS     if (success != null): success();
			case FAIL(error) if (fail    != null): fail(error);
			default:
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome, depending on the supplied outcome.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	 * @param fail    Handler called if the outcome is a failure.
	**/
	inline static public function splitHandlers<E>
	( outcome :Outcome<E>
	, ?success:(Outcome<E>)->Void
	, ?fail   :(Outcome<E>)->Void
	) {
		switch outcome {
			
			case SUCCESS     if (success != null): success(outcome);
			case FAIL(error) if (fail    != null): fail   (outcome);
			default:
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, if the outcome was successful.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	**/
	inline static public function successHandler<E>
	( outcome:Outcome<E>
	, success:()->Void
	) {
		switch outcome {
			
			case FAIL(_): // nothing
			case SUCCESS: success();
		}
	}
	
	/**
	 * Calls the corresponding handler, with the outcome's value, if the outcome was successful.
	 * Otherwise, an error is thrown.
	 * 
	 * @param outcome The outcome.
	 * @param success Handler called if the outcome is successful.
	**/
	inline static public function assertSuccessHandler<E>
	( outcome:Outcome<E>
	, success:()->Void
	) {
		switch outcome {
			
			case SUCCESS: success();
			case FAIL(error): throw error;
		}
	}
	
	/**
	 * Throws an error if the result is a failure.
	 * 
	 * @param outcome The outcome.
	**/
	inline static public function assert<E>(outcome:Outcome<E>, ?msgPrefix:String) {
		
		if (msgPrefix == null)
			msgPrefix = "";
		else
			msgPrefix += " ";
		
		switch outcome {
			
			case FAIL(error): throw msgPrefix + Std.string(error);
			case SUCCESS: //nothing
		}
	}
	
	inline static public function errorToString<E>(outcome:Outcome<E>):Outcome<String> {
		
		return switch(outcome) {
			
			case SUCCESS: SUCCESS;
			case FAIL(error): FAIL(Std.string(error));
		}
	}
}
