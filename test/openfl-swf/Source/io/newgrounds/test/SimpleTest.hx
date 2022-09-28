package io.newgrounds.test;

import io.newgrounds.Call;
import io.newgrounds.NG;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Outcome;

class SimpleTest {
	
	public function new() {
		
		trace("connecting to newgrounds");
		
		// Use debug so medal unlocks and scoreboards reset after this session
		var debug = true;
		NG.createAndCheckSession("47215:Ip8uDj9v", debug);
		NG.core.verbose = true;
		// Set the encryption cipher/format to RC4/Base64. AES128 and Hex are not implemented yet
		// Found in your NG project view
		NG.core.setupEncryption("LrnXpr/ogBf+GmU97IzF7Q==");
		// NG.core.setupEncryption("LrnXpr/ogBf+GmU97IzF7Q==", HEX);
		// NG.core.setupEncryption("LrnXpr/ogBf+GmU97IzF7Q==", NONE);
		// NG.core.setupEncryption("LUp0Zg4f1lukgKgSwchZnQ==", RC4, BASE_64);
		// NG.core.setupEncryption("2d4a74660e1fd65ba480a812c1c8599d", RC4, HEX);// Found in your NG project view
		
		if (NG.core.attemptingLogin) {
			
			/* a session_id was found in the loadervars, this means the user is playing on newgrounds.com
			 * and we should login shortly. lets wait for that to happen
			 */
			
			NG.core.onLogin.add(onNGLogin);
			
		} else {
			
			/* They are NOT playing on newgrounds.com, no session id was found. We must start one manually, if we want to.
			 * Note: This will cause a new browser window to pop up where they can log in to newgrounds
			 */
			NG.core.requestLogin((r)->{ if (r.match(SUCCESS)) onNGLogin(); } );
		}
	}
	
	function onNGLogin() {
		
		trace ('logged in! user:${NG.core.user.name}');
		
		// Load medals then call onNGMedalFetch()
		NG.core.medals.loadList(onNGMedalFetch);
		
		// Load Scoreboards then call onNGBoardsFetch()
		NG.core.scoreBoards.loadList(onNGBoardsFetch);
		
		// Load SaveSlots then call onNGSlotsFetch()
		// NG.core.requestSaveSlots(true, onNGSlotsFetch);
		NG.core.saveSlots.loadAllFiles(onNGSlotsFetch);
	}
	
	// --- MEDALS
	function onNGMedalFetch(outcome:Outcome<CallError>) {
		
		switch (outcome) {
			case FAIL(error): throw 'Error loading medals: $error';
			case SUCCESS:
		}
		
		// Reading medal info
		for (id in NG.core.medals.keys()) {
			
			var medal = NG.core.medals[id];
			trace('loaded medal id:$id, name:${medal.name}, description:${medal.description}');
		}
		
		// Unlocking medals
		var unlockingMedal = NG.core.medals[54001];// medal ids are listed in your NG project viewer 
		if (!unlockingMedal.unlocked)
			unlockingMedal.sendUnlock();
	}
	
	// --- SCOREBOARDS
	function onNGBoardsFetch(outcome:Outcome<CallError>) {
		
		outcome.assert('Error loading score boards:');
		
		// Reading medal info
		for (id in NG.core.scoreBoards.keys()) {
			
			var board = NG.core.scoreBoards[id];
			trace('loaded scoreboard id:$id, name:${board.name}');
		}
		
		var board = NG.core.scoreBoards[7971];// ID found in NG project view
		
		// Posting a score thats OVER 9000!
		board.postScore(9001);
		
		// --- To view the scores you first need to select the range of scores you want to see --- 
		
		// add an update listener so we know when we get the new scores
		board.onUpdate.add(onNGScoresFetch);
		board.requestScores(10);// get the best 10 scores ever logged
		// more info on scores --- http://www.newgrounds.io/help/components/#scoreboard-getscores
	}
	
	function onNGScoresFetch() {
		
		for (score in NG.core.scoreBoards[7971].scores)
			trace('score loaded user:${score.user.name}, score:${score.formattedValue}');
	}
	
	function onNGSlotsFetch(outcome:Outcome<CallError>) {
		
		outcome.assert('Error getting saveSlots:');
		
		for (k=>slot in NG.core.saveSlots)
			trace('[$k]=>{url:${slot.url}, time:${slot.datetime}, size:${slot.size}}');
		
		advanceSong(waitForClick);
	}
	
	function advanceSong(callback) {
		
		var slot = NG.core.saveSlots[1];
		if (slot.url == null) {
			
			trace("Saving default value to slot 1");
			buySomeMore(slot, callback);
			
		} else
			takeOneDown(slot, callback);
	}
	
	function waitForClick(slot:SaveSlot) {
		
		#if openfl
		openfl.Lib.current.stage.addEventListener(openfl.events.MouseEvent.CLICK, onClick);
		#end
	}
	
	#if openfl
	function onClick(e:openfl.events.MouseEvent) {
		
		openfl.Lib.current.stage.removeEventListener(openfl.events.MouseEvent.CLICK, onClick);
		
		advanceSong(waitForClick);
	}
	#end
	
	function buySomeMore(slot:SaveSlot, callback:(SaveSlot)->Void) {
		
		saveSlot(slot, "99 bottles of beer", callback);
	}
	
	function takeOneDown(slot:SaveSlot, callback:(SaveSlot)->Void) {
		
		var bottles = Std.parseInt(slot.contents.split(" ")[0]);
		switch(slot.contents) {
			
			case "0 bottles of beer":
				// no more
				clearSlot(slot, callback);
			case data if(bottles > 0):
				// pass it around
				saveSlot(slot, '${bottles - 1} bottles of beer', callback);
			case data:
				trace('Unexpected save contents "$data"');
				clearSlot(slot, callback);
		}
	}
	
	function saveSlot(slot:SaveSlot, value:String, callback:(SaveSlot)->Void) {
		
		trace('Saving slot[${slot.id}]: "${slot.contents}"->"$value"');
		slot.save(value, (r)->{
			switch(r) {
				
				case SUCCESS: trace('data saved: "$value"');
				case FAIL(e): trace('Error saving data: "$e"');
			}
			callback(slot);
		});
	}
	
	function clearSlot(slot:SaveSlot, callback:(SaveSlot)->Void) {
		
		trace('Clearing slot[${slot.id}]: "${slot.contents}"');
		slot.clear((r)->{
			switch(r) {
				case SUCCESS: trace('data cleared');
				case FAIL(e): trace('Error clearing data: $e');
			}
			callback(slot);
		});
	}
}
