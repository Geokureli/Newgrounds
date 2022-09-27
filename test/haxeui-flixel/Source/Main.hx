package ;

import haxe.ui.Toolkit;
import haxe.ui.core.Screen;

class Main extends openfl.display.Sprite
{
    public function new()
    {
        super();
        
        Toolkit.init();
        Toolkit.theme = "dark";
        Toolkit.scaleX = Toolkit.scaleY = 1;
        addChild(new flixel.FlxGame(0, 0, states.IntroState));
    }
}
