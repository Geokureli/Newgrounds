package dialogs;

import io.newgrounds.NG;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.macros.ComponentMacros.build("Assets/data/dialogs/passport.xml"))
class Passport extends Dialog
{
    public function new()
    {
        super();
        
        buttons = DialogButton.CANCEL | DialogButton.OK;
    }
    
    public override function validateDialog(button:DialogButton, fn:Bool->Void)
    {
        if (button == DialogButton.OK)
            NG.core.openPassportUrl();
        else
            NG.core.cancelLoginRequest();
        
        fn(true);
    }
}