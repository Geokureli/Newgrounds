package dialogs;

import io.newgrounds.NG;
import io.newgrounds.objects.SaveSlot;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.macros.ComponentMacros.build("Assets/data/dialogs/saveslot.xml"))
class SaveSlotContents extends Dialog
{
	var slot:SaveSlot;
	
	public function new()
	{
		super();
		
		buttons = DialogButton.OK;
	}
	
	public function showSlot(slot:SaveSlot)
	{
		this.slot = slot;
		slot.onUpdate.add(updateDisplay);
		showDialog();
		updateDisplay();
	}
	
	function updateDisplay()
	{
		body.text = 'Slot ${slot.id} ';
		if (slot.isEmpty())
		{
			body.text += 'Empty';
			contents.disabled = false;
			contents.placeholder = "Input save data and press \"Save\"";
			loadButton.disabled = true;
			clearButton.disabled = true;
		}
		else
		{
			body.text += slot.datetime + ' ' + slot.prettyPrintSize();
			
			final contentsLoaded = slot.contents != null;
			final emptyContents = slot.contents == null;
			contents.placeholder = contentsLoaded ? null : "Press \"Load\" to fetch the save contents";
			contents.text = contentsLoaded ? slot.contents : "";
			contents.disabled = emptyContents;
			loadButton.disabled = contentsLoaded;
			saveButton.disabled = emptyContents;
			clearButton.disabled = false;
		}
	}
	
	@:bind(loadButton, MouseEvent.CLICK)
	function clickLoad(_)
	{
		slot.load();
	}
	
	@:bind(saveButton, MouseEvent.CLICK)
	function clickSave(_)
	{
		slot.save(contents.text);
	}
	
	@:bind(clearButton, MouseEvent.CLICK)
	function clickClear(_)
	{
		slot.clear();
	}
	
	override function validateDialog(button:DialogButton, fn:Bool->Void)
	{
		slot.onUpdate.remove(updateDisplay);
		slot = null;
		
		fn(true);
	}
}