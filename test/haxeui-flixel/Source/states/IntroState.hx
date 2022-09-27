package states;

import states.MainState;
import haxe.ui.containers.Box;
import haxe.ui.components.Label;
import haxe.ui.events.UIEvent;
import haxe.ui.events.MouseEvent;

import flixel.FlxG;

import io.newgrounds.NGLite;
import io.newgrounds.crypto.Cipher;
import io.newgrounds.crypto.EncodingFormat;

class IntroState extends flixel.FlxState
{
    override function create() add(new IntroView());
}

@:build(haxe.ui.ComponentBuilder.build("assets/intro.xml"))
class IntroView extends Box
{
    override function onReady()
    {
        super.onReady();
        
        changeCheckLoaderVars();
    }
    
    @:bind(start, MouseEvent.CLICK)
    function clickStart(_)
    {
        var cipher:Cipher = NONE;
        var format:EncodingFormat = BASE_64;
        if (none.selected == false)
        {
            cipher = aes128.selected ? AES_128 : RC4;
            format = base64.selected ? BASE_64 : HEX;
        }
        
        FlxG.switchState(new MainState
            ( appId.text
            , sessionId.text
            , debug.selected
            , encKey.text
            , cipher
            , format
            )
        );
    }
    
    @:bind(checkLoaderVars, UIEvent.CHANGE)
    function changeCheckLoaderVars(?_)
    {
        if (checkLoaderVars.disabled)
            return;
        
        var loaderVarSessionId = NGLite.getSessionId();
        if (loaderVarSessionId == null)
        {
            sessionId.text = "";
            checkLoaderVars.disabled = true;
            checkLoaderVars.selected = false;
        }
        
        if (checkLoaderVars.selected)
        {
            sessionId.disabled = true;
            sessionId.text = loaderVarSessionId;
        }
        else
            sessionId.disabled = false;
    }
}