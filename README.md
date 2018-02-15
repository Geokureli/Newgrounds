# Newgrounds.hx

Before using this library make sure you have read the 
<a href="http://www.newgrounds.io/">Introduction to Newgrounds.io</a>!

####Installing the library

**using haxelib:** (not implemented yet)
`haxelib install newgrounds`

just use git...

####Implement an instance of io.newgrounds.core into your game:

**OpenFL:** add `<haxelib name="newgrounds" />` to your project.xml

If you don't want to include openfl in your project, or you just hate my shitty core helpers, 
you can enable the compiler flag `ng_lite`. and it removes all openfl dependencies, 
but limits NG.core's functionality to basic component calls and responses

First create the core

`NG.create("app id here", "session id, here, if you know it");`

When your game is being played on Newgrounds.com you can find the sessionId in the loaderVars,
or you can have the API find it automatically with

`NG.createAndCheckSession(myGame.stage, "app id here");`

This will also determine the host that will be used when logging events. 
Once the core is created you can access it via NG.core but this is not possible if the core was instantiated directly

If no session ID was found, you will need to start one.

`if (NG.core.loggedIn == false) { NG.core.requestLogin(onSuccess); }`

`testCode():Void {
    doStuff();
}`


####Using fla assets
If your project already uses a .swf you can add them to your .fla 
and they will automatically listen to your core for events. 
You can also instantiate them in code. These assets work with ng_lite enabled (with caveats)

**MedalPopup:** Just add it where you want it to show and it will 
autoplay when you call medal.unlock(), and the server response with a success event. 
If multiple achievements are unlocked at the same time they will play one after another

_**Note:** If the ng_lite compiler flag is true this will not automatically appear,
you must call playAnim(iconDisplayObj, medalName, medalPoints).
If ng_lite is false MedalPopup will request medals as soon as you start a NG.io session_

**ScoreBrowser:** Once it's added to the stage and a NG.io has started it loads board data, 
it has the following public properties
 - **boardId:** The numeric ID of the scoreboard to display. Defaults to the first ID sent back from the server.
 - **period:** The time-frame to pull scores from (see notes for acceptable values). Defaults to all-time
 - **title:** The title of the scoreBrowser, defaults to whatever the swf already has.
 - **tag:** A tag to filter results by
 - **social:** Whether to only list scores by the user and their friends, defaults to false



TODO
 - better readme.md
 - AES-128 encryption
 - Hex encoding
 - kill all humans
 - flash API assets
     - ad viewer - not supported in ng.io v3
     - auto connector - requires ads?
 - fix checkbox disabled state
 - continuous integrations
 - local storage
    - save unsent medal unlocks and scoreboard posts
    - save previous session rather than creating a new one