package pages;

import haxe.ui.events.MouseEvent;

import io.newgrounds.NG;
import io.newgrounds.components.ScoreBoardComponent;

@:build(haxe.ui.ComponentBuilder.build("Assets/data/pages/scoreboard.xml"))
class ScoreBoardPage extends Page
{
    @:bind(getBoards, MouseEvent.CLICK)
    function clickGetBoards(_) send(NG.core.calls.scoreBoard.getBoards());
    
    @:bind(getScores, MouseEvent.CLICK)
    function clickGetScores(_)
    {
        if (flashInvalidSession()) return;
        final periodValues:Array<Period> = [DAY, WEEK, MONTH, YEAR, ALL];
        send(NG.core.calls.scoreBoard.getScores
            ( Std.parseInt(getScoresId.text)
            , Std.int(limit.pos)
            , Std.int(skip.pos)
            , periodValues[period.selectedIndex]
            , social.selected
            , user.text
            )
        );
    }
    
    @:bind(postScore, MouseEvent.CLICK)
    function clickPostScore(_)
    {
        if (flashInvalidSession()) return;
        if (flashInvalidText(score)) return;
        send(NG.core.calls.scoreBoard.postScore(Std.parseInt(getScoresId.text), Std.parseInt(score.text)));
    }
}