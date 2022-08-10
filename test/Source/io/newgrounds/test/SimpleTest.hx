package io.newgrounds.test;

import io.newgrounds.NG;
import io.newgrounds.objects.events.ResultType;

class SimpleTest {
	
	public function new() {
		
		trace("connecting to newgrounds");
		
		NG.createAndCheckSession("47215:Ip8uDj9v");
		NG.core.verbose = true;
		// Set the encryption cipher/format to RC4/Base64. AES128 and Hex are not implemented yet
		NG.core.initEncryption("LUp0Zg4f1lukgKgSwchZnQ==");// Found in your NG project view
		
		if (NG.core.attemptingLogin)
		{
			/* a session_id was found in the loadervars, this means the user is playing on newgrounds.com
			 * and we should login shortly. lets wait for that to happen
			 */
			
			NG.core.onLogin.add(onNGLogin);
		}
		else
		{
			/* They are NOT playing on newgrounds.com, no session id was found. We must start one manually, if we want to.
			 * Note: This will cause a new browser window to pop up where they can log in to newgrounds
			 */
			NG.core.requestLogin(onNGLogin);
		}
	}
	
	function onNGLogin():Void
	{
		trace ('logged in! user:${NG.core.user.name}');
		
		// Load medals then call onNGMedalFetch()
		NG.core.requestMedals(onNGMedalFetch);
		
		// Load Scoreboards then call onNGBoardsFetch()
		NG.core.requestScoreBoards(onNGBoardsFetch);
		
		// Load SaveSlots then call onNGSlotsFetch()
		NG.core.requestSaveSlots(onNGSlotsFetch);
	}
	
	// --- MEDALS
	function onNGMedalFetch():Void
	{
		// Reading medal info
		for (id in NG.core.medals.keys())
		{
			var medal = NG.core.medals.get(id);
			trace('loaded medal id:$id, name:${medal.name}, description:${medal.description}');
		}
		
		// Unlocking medals
		var unlockingMedal = NG.core.medals.get(54001);// medal ids are listed in your NG project viewer 
		if (!unlockingMedal.unlocked)
			unlockingMedal.sendUnlock();
	}
	
	// --- SCOREBOARDS
	function onNGBoardsFetch():Void
	{
		// Reading medal info
		for (id in NG.core.scoreBoards.keys())
		{
			var board = NG.core.scoreBoards.get(id);
			trace('loaded scoreboard id:$id, name:${board.name}');
		}
		
		var board = NG.core.scoreBoards.get(7971);// ID found in NG project view
		
		// Posting a score thats OVER 9000!
		board.postScore(9001);
		
		// --- To view the scores you first need to select the range of scores you want to see --- 
		
		// add an update listener so we know when we get the new scores
		board.onUpdate.add(onNGScoresFetch);
		board.requestScores(10);// get the best 10 scores ever logged
		// more info on scores --- http://www.newgrounds.io/help/components/#scoreboard-getscores
	}
	
	function onNGScoresFetch():Void
	{
		for (score in NG.core.scoreBoards.get(7971).scores)
		{
			trace('score loaded user:${score.user.name}, score:${score.formattedValue}');
		}
	}
	
	function onNGSlotsFetch(result:ResultType) {
		
		switch (result) {
			
			case Error(e):
				trace('Error getting saveSlots');
				return;
			
			case Success:
		}
		
		for (k=>slot in NG.core.saveSlots)
			trace('[$k]=>{url:${slot.url}, time:${slot.datetime}}');
		
		var slot = NG.core.saveSlots[1];
		if (slot.url == null) {
			
			trace("Saving default value to slot 1");
			slot.save("default data", (s)->trace('data saved: "$s"'));
			
		} else {
			
			slot.load((result)-> {
				
				var saveData:String;
				switch (result) {
					
					case Error(e):
						trace("Error loading slot 1: " + e);
						return;
					
					case Success(s):
						saveData = s;
				}
				
				function save(value:String) {
					
					trace('SaveSlot[1]: "$saveData"->"$value"');
					slot.save(value, (r)->{
						switch(r) {
							
							case Success(s): trace('data saved: "$s"');
							case Error(e): trace('Error saving data: "$e"');
						}
					});
				}
				
				function clear() {
					
					trace('SaveSlot[1]: "$saveData"');
					slot.clear((r)->{
						switch(r) {
							case Success(_): trace('data cleared');
							case Error(e): trace('Error clearing data: $e');
						}
					});
				}
				
				switch(saveData) {
					
					case "default data": save("");
					case ""            : save("test");
					case "test"        : clear();
					default: throw "unexpected save data";
				}
			});
		}
	}
}
