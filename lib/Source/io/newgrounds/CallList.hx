package io.newgrounds;

import io.newgrounds.objects.events.BaseResultData;

class CallList {
	
	final list = new Array<Call<Dynamic>>();
	
	public function new () {}
	
	public function add<T:BaseResultData>(call:Call<T>):Call<T>
	{
		list.push(call);
		call.onComplete.add(function () {
			
			list.remove(call);
			checkQueue();
		});
		return call;
	}
	
	public function checkQueue()
	{
		if (false == Lambda.exists(list, (c)->c.state.match(SENT)))
		{
			final next = Lambda.find(list, (c)->c.state.match(QUEUED));
			if (next != null)
				next.send();
		}
	}
}