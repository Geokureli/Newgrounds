package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;
import io.newgrounds.components.ScoreBoardComponent;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/radio.xml"))
class RadioPage extends Page
{
	var isStreaming = false;
	
	@:bind(stream, MouseEvent.CLICK)
	function clickStream(_)
	{
		if (isStreaming)
			stopStream();
		else
			startStream();
	}
	
	inline function stopStream()
	{
		stream.text = "Stream";
		isStreaming = false;
	}
	
	inline function startStream()
	{
		stream.text = "Stop";
		isStreaming = true;
		
		var http = new haxe.Http("https://stream.newgroundsradio.com/radio.mp3");
		http.onBytes = onBytes;
		http.onData = onData;
		http.onError = onError;
		http.onStatus = onStatus;
		flixel.FlxG.signals.preUpdate.add
		(
			function ()
			{
				trace("responseBytes" + http.responseBytes);
				trace("responseData" + http.responseData);
			}
		);
		http.request(false);
	}
	
	function onBytes(bytes:haxe.io.Bytes)
	{
		trace("bytes: " + bytes);
	}
	
	function onData(data:String)
	{
		trace("data: " + data);
	}
	
	function onError(error:String)
	{
		trace("error: " + error);
	}
	
	function onStatus(status:Int)
	{
		trace("data: " + status);
	}
}