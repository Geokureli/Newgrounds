package ;

// import haxe.ui.HaxeUIApp;

// class Main {
//     public static function main() {
//         var app = new HaxeUIApp();
//         app.ready(function() {
//             app.addComponent(new MainView());
//             
//             app.start();
//         });
//     }
// }

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
        addChild(new flixel.FlxGame(0, 0, BootState));
    }
}

class BootState extends flixel.FlxState
{
    override function create()
    {
        add(new MainView());
        // addTest();
    }
    
    function addTest()
    {
        add(haxe.ui.ComponentBuilder.fromString
        ('  <vbox style="padding: 5px;">
                <style>
                    .button { font-size: 20px; }
                </style>
                <hbox>
                    <button text="Click Me!" id="button1" style="color: red;" />
                    <button text="Click Me!" id="button2" style="color: green;" />
                    <button text="Click Me!" onclick="this.text=\'Thanks!\'" style="color: blue;" />
                </hbox>
            </vbox>
        '));
    }
}

// @:build(haxe.ui.ComponentBuilder.build("assets/test.xml"))
// class Test extends haxe.ui.containers.VBox
// {
//     override function onReady()
//     {
//     }
// }