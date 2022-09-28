package io.newgrounds.test.ui;

import openfl.display.MovieClip;
import openfl.text.TextField;

import io.newgrounds.Call;
import io.newgrounds.components.CloudSaveComponent;
import io.newgrounds.objects.Error;

#if ng_lite
	import io.newgrounds.objects.events.Response;
	import io.newgrounds.objects.events.Result.LoadSlotsResult;
#else
	import io.newgrounds.objects.events.Outcome;
	import io.newgrounds.objects.SaveSlot;
#end

import io.newgrounds.swf.common.Button;
import io.newgrounds.test.art.CloudSavesPageSwf;

class CloudSavePage extends Page<CloudSaveComponent> {
	
	var _loading:TextField;
	var _slotList:SlotList;
	var _slotData:TextField;
	var _clearButton:Button;
	var _saveButton:Button;
	var _loadButton:Button;
	var _contents:TextField;
	
	
	public function new (target:CloudSavesPageSwf) {
		super(target, NG.core.calls.cloudSave);
		
		_loading = target.loading;
		_contents = target.save;
		_contents.wordWrap = true;
		_slotData = target.slotData;
		_slotList = new SlotList(target.slotList, onSlotSelect);
		
		_clearButton = new Button(target.clearButton, onClickClear);
		_saveButton  = new Button(target.saveButton , onClickSave );
		_loadButton  = new Button(target.loadButton , onClickLoad );
		setContents(false, "");
		
		#if ng_lite
		// --- FIND SCOREBOARD TO SET ID
		NG.core.calls.cloudSave.loadSlots()
			.addDataHandler(onSlotsReceived)
			.queue();
		
		setMessage("Loading...");
		#else
		switch (NG.core.saveSlots.state) {
			
			case Empty if (NG.core.loggedIn == false):
				
				setMessage("Login to get save slots");
				NG.core.onLogin.addOnce(function () {
					
					if (NG.core.saveSlots.state != Loaded)
						setMessage("Loading...");
					
					NG.core.saveSlots.loadList(onSlotsReceived);
				});
				
			default:
				
				NG.core.saveSlots.loadList(onSlotsReceived);
				setMessage("Loading...");
				
		}
		#end
	}
	
	#if ng_lite
	function onSlotsReceived(response:CallOutcome<LoadSlotsResult>):Void {
		
	}
	#else
	function onSlotsReceived(outcome:Outcome<CallError>):Void {
		
		switch(outcome) {
			
			case FAIL(error):
				
				setMessage("Error loading save slots: " + error);
				
			case SUCCESS:
				
				setMessage(null);
				
				_slotList.onSlotsRecieved();
		}
	}
	#end
	
	function setMessage(msg:Null<String>) {
		
		_loading.visible = msg != null;
		_clearButton.enabled = msg == null;
		_saveButton.enabled  = msg == null;
		_loadButton.enabled  = msg == null;
		_slotData.visible = msg == null;
		
		if (msg == null) msg = " ";
		
		_loading.text = msg;
	}
	
	function onSlotSelect(id:Int) {
		
		var slot = NG.core.saveSlots[id];
		
		if (slot.url == null) {
			
			setContents(true, "");
			_slotData.text = 'ID: ${slot.id} - Empty';
			
		} else {
			
			_slotData.text = 'ID: ${slot.id} Last Saved: ${slot.getDate())} Size: ${slot.size} bytes';
			
			if (slot.contents == null)
				setContents(false, "Press LOAD to fetch the save contents.");
				
			else
				setContents(true, slot.contents);
		}
	}
	
	inline function setContents(canEdit:Bool, text:String) {
		
		if (canEdit) {
			
			_contents.type = INPUT;
			_contents.backgroundColor = 0xFFffffff;
			
		} else {
			
			_contents.type = DYNAMIC;
			_contents.backgroundColor = 0xFF404040;
		}
		
		_contents.text = text;
	}
	
	function reselectSlot() {
		
		if (_slotList.selectedId == -1)
			throw "No slot selected, cannot redraw";
		
		onSlotSelect(_slotList.selectedId);
	}
	
	function assertCurrentSlot():SaveSlot {
		
		if (_slotList.selectedId == -1)
			throw "Assertion Fail: No current slot selected";
		
		return NG.core.saveSlots[_slotList.selectedId];
	}
	
	function onClickClear() {
		
		assertCurrentSlot().clear((_)->reselectSlot());
	}
	
	function onClickSave() {
		
		assertCurrentSlot().save(_contents.text, (_)->reselectSlot());
	}
	
	function onClickLoad() {
		
		assertCurrentSlot().load((_)->reselectSlot());
	}
}

private class SlotList {
	
	public var selectedId(default, null):Int = -1;
	
	var _target:MovieClip;
	var _callback:(Int)->Void;
	var _buttons = new Map<Int, CheckBox>();
	
	public function new (slotList:MovieClip, callback:(Int)->Void) {
		
		_target = slotList;
		_callback = callback;
		
		_target.visible = false;
	}
	
	public function onSlotsRecieved() {
		
		_target.visible = true;
		var saveSlots = NG.core.saveSlots;
		var numSlots = saveSlots.length;
		
		if (numSlots == 0)
			throw 'Server returned no slots';
		
		if (numSlots > _target.numChildren)
			throw 'Save slot count exceeded expectations, slots: $numSlots, buttons: ${_target.numChildren}';
		
		for (i in 0...numSlots) {
			
			var slot = saveSlots.getOrdered(i);
			var slotMc:MovieClip = cast _target.getChildByName('slot$i');
			
			if (slotMc == null)
				throw 'missing slot$i';
			
			var button = new CheckBox(slotMc, onSelect.bind(slot.id));
			button.setLabel(Std.string(slot.id));
			_buttons[slot.id] = button;
		}
		
		// find the center;
		var center = _target.x + _target.width / 2;
		
		// remove the rest
		for (i in numSlots..._target.numChildren) {
			
			var slotMc:MovieClip = cast _target.getChildByName('slot$i');
			
			if (slotMc == null)
				throw 'missing slot$i';
			
			_target.removeChild(slotMc);
		}
		
		// recenter the remaining
		_target.x = center - _target.width / 2;
		
		// select first slot
		var firstSlot = saveSlots.getOrdered(0).id;
		onSelect(firstSlot);
		_buttons[firstSlot].on = true;
	}
	
	function onSelect(id) {
		
		if (selectedId != -1)
			_buttons[selectedId].on = false;
		
		selectedId = id;
		// _buttons[selectedId].on = true;
		
		_callback(id);
	}
}