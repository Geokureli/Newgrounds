package components;

import io.newgrounds.NG;
import io.newgrounds.Call;
import io.newgrounds.objects.SaveSlot;
import io.newgrounds.objects.events.Outcome;

import dialogs.SaveSlotContents;

typedef SlotItem = { slotId:String, time:String, size:String };

@:build(haxe.ui.ComponentBuilder.build("Assets/data/components/cloudsaves.xml"))
class CloudSaves extends haxe.ui.containers.VBox
{
	public function new () { super(); }
	
	override function onReady()
	{
		super.onReady();
		
		clearList();
	}
	public function loadSlots()
	{
		NG.core.saveSlots.loadList(onSlotsReceive);
	}
	
	function onSlotsReceive(outcome:Outcome<CallError>)
	{
		switch outcome
		{
			case FAIL(_):// TODO:
			case SUCCESS:
			{
				for (slot in NG.core.saveSlots)
				{
					function updateSlot(slot:SaveSlot)
					{
						saveSlots.dataSource.update(slot.id - 1,
							{ slotId : slot.id
							, time : slot.isEmpty() ? "Empty" : slot.datetime
							, size: slot.prettyPrintSize()
							}
						);
					}
					slot.onUpdate.add(updateSlot.bind(slot));
					updateSlot(slot);
				}
				
				saveSlots.onChange = function (e)
				{
					new SaveSlotContents().showSlot(NG.core.saveSlots[saveSlots.selectedIndex + 1]);
				}
			}
		}
	}
	
	function clearList()
	{
		for (i in 0...saveSlots.dataSource.size)
		{
			saveSlots.dataSource.update(i, { slotId : " ", time : " ", size: " " });
		}
		saveSlots.onClick = null;
	}
}