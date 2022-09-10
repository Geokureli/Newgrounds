[![MIT License](https://img.shields.io/github/license/geokureli/newgrounds.svg?style=flat)](LICENSE.md)
[![Haxelib Version](https://img.shields.io/github/tag/geokureli/newgrounds.svg?style=flat&label=haxelib)](https://lib.haxe.org/p/newgrounds/)

# Newgrounds

Before using this library make sure you have read the 
<a href="http://www.newgrounds.io/">Introduction to Newgrounds.io</a>!

If you're confused by anything be sure to 
<a href="https://www.newgrounds.com/projects/games/1181322/preview/">try out the test project</a>.

## Installing the library

**using haxelib:**
`haxelib install newgrounds`

## Implement an instance of io.newgrounds.core into your game:

Add `<haxelib name="newgrounds" />` to your project.xml.
You can also just include the local library in your xml
via `<classpath path="../[libr path]/lib/src" />`

If you hate my shitty core helpers, you can enable
the compiler flag `ng_lite` to limit NG.core's
functionality to basic component calls and responses.

### Creating the core

```haxe
NG.create("app id here", "session id, here, if you know it");
```

Once the core is created you can access it via NG.core but 
this is not possible if the core was instantiated directly.

When your game is being played on Newgrounds.com you can
find the sessionId in the loaderVars, or you can have the
API find it automatically with

```haxe
NG.createAndCheckSession("app id here", "backup session id, if none is found");
```


This will also determine the host that will be used when
logging events (except when ng_lite is active). You can
also set or change the host using `NG.core.host`. The
host is used to track views and various other events logged
to NG.io.

### Manual Login

If no session ID was found, you will need to start one.

```haxe
if (NG.core.loggedIn == false) {
    NG.core.requestLogin(
        function(outcome:LoginOutcome):Void {
            if (outcome.match(SUCCESS))
                trace("logged on");
        }
    );
}
```

### Encryption

Setting the encryption method is easy, just call:

```haxe
NG.core.setupEncryption("encryption key", AES_128, BASE_64);
```

Encryption Ciphers:
- **io.newgrounds.crypto.Cipher.NONE**
- **io.newgrounds.crypto.Cipher.AES-128**(default)
- **io.newgrounds.crypto.Cipher.RC4**

Encryption Ciphers:
- **io.newgrounds.crypto.EncryptionFormat.BASE_64** (default)
- **io.newgrounds.crypto.EncryptionFormat.HEX**

You can also use your own encryption method - if you're some kind of crypto-god from The Matrix -
by directly setting NG.core.encryptionHandler

#### Example
```haxe
NG.core.encryptionHandler = myEncryptionHandler;

function myEncryptionHandler(data:String):String {
    
    var encrytedData:String;
    // stuff
    return encrytedData;
}
```

## Using fla assets
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

## Using Core Objects
Using core methods will cause the core to automatically keep track of server data in the underlying calls. 
much like how `NG.core.requestLogin()` stores the resulting sessionId for future calls, Medal and Scoreboard 
data is maintained from NG.core methods, but not direct `NG.core.calls` 

### Medals 
Use `NG.core.medals.loadList()` to populate `NG.core.medals`, once Medal objects are created 
you can interface with them directly. For instance: 
```haxe
var medal =  NG.core.medals.get(id);
trace('${medal.name} is worth ${medal.value}');

if (!medal.unlocked) {
    
    medal.onUnlock.add(function ():Void { trace('${medal.name} unlocked:${medal.unlocked}'); });
    medal.unlock();
}
```

### ScoreBoards
Just like Medals `NG.core.scoreBoards` is populated from `NG.core.scoreBoards.loadList()` 
which allows you make postScore and getScores calls directly on the board.

**Note:** ScoreBoard instances persist across multiple scoreBoards.loadList calls, but a ScoreBoard's score instances do not

### CloudSaves
Similarly to medals and scoreboards CloudSaves have `NG.core.saveSlots` which is populated by `NG.core.saveSlots.loadList`.
On top of the normal [SaveSlot properties](http://www.newgrounds.io/help/objects/#SaveSlot), each saveSlot will have a
readonly `contents` field that is null until you call `load` on that SaveSlot instance (`load()` will throw an error
if there is no save in that slot, check this using `isEmpty()`). You can also call `save(mySaveContents)` or `clear()` on
SaveSlots.

## Calling Components and Handling Outcomes
You can talk to the NG.io server directly, but NG.core won't automatically handle 
the response for you (unlike NG.core.requestMedals()). All of the component calls are 
in `NG.core.call.[componentName].[callName]("call args")`

#### Example:
```haxe
var call = NG.core.calls.medal.unlock(medalId);
call.send();
```

### Handling responses
You can add various listeners to a call to track successful or unsuccessful responses from the NG server.

```haxe
var call = NG.core.calls.medal.unlock(medalId);
call.addOutcomeHandler(onMedalUnlockDataReceived);
call.send();
```

The various calls types result in different response data structures. For instance medal.unlock 
responds with a `CallOutcome<io.newgrounds.objects.events.Data>` object. The outcome type determines the data 
contained in the `SUCCESS(data)`. 

#### Example Usage:

```haxe
var call = NG.core.calls.medal.unlock(medalId);
call.addOutcomeHandler(
    function(outcome:CallOutcome<MedalUnlockData>):Void {
        
        switch(outcome) {
            
            case SUCCESS(data): trace('Medal unlocked, [name=${data.medal.name}]');
            case FAIL(error): trace('Error unlocking medal: ' + error.toString());
        }
    }
);
call.send();
```

You can use `myCall.addSuccessHandler(function():Void { trace("success"); });` 
to only listen for successful responses from the server

You can also use myCall.addErrorHandler to listen for errors thrown by NG server, or errors
resulting from general Http remoting

```haxe
myCall.addErrorHandler(
    function(e:io.newgrounds.objects.Error):Void {
        
        trace('Error: $e');
    }
);
```

### Chaining call methods
All Call methods support chaining, meaning you can setup your calls without using local vars.
```haxe
NG.core.call.medalUnlock(id)
    .setProperty("debug", true)
    .addSuccessHandler(onSuccess)
    .addErrorHandler(onFail)
    .addStatusHandler(onStatusChange)
    .send();
```

### Queueing calls
All calls can be queued so that they are sent sequentially rather than sending them all at once.

```haxe
NG.core.session = "session id here";
NG.core.calls.app.checkSession().queue();
NG.core.calls.medal.unlock(id).queue();
```

## TODO
 - ~~AES-128 encryption~~
 - ~~Hex encoding~~
 - ~~Enable AES-128 and Hex in the GUI test project~~
 - ~~Pretty up the GUI test project in general~~
 - ~~Replace successCallbacks and failCallbacks with outcomeCallbacks (2.0.0)~~
 - Explain OutcomeTools in readme
 - kill all humans
 - flash API assets
     - ad viewer - not supported in ng.io v3
     - auto connector - requires ads?
 - continuous integrations
 - local storage
    - save unsent medal unlocks and scoreboard posts
    - save previous session rather than creating a new one
 - allow synchronous http requests
