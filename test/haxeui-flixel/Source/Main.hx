package ;

class Main extends openfl.display.Sprite
{
    public function new()
    {
        super();
        
        var toolkit = haxe.ui.Toolkit;
        toolkit.init();
        toolkit.theme = "dark";
        toolkit.scaleX = toolkit.scaleY = 1;
        addChild(new flixel.FlxGame(0, 0, states.IntroState));
    }
}
