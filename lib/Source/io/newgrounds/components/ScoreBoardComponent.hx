package io.newgrounds.components;

import io.newgrounds.net.Call;
import io.newgrounds.net.data.Period;
import io.newgrounds.net.data.Score;
import io.newgrounds.net.data.User;
import io.newgrounds.net.results.score.*;

class ScoreBoardComponent extends Component {
	
	public function new (core){ super(core); }
	
	// -------------------------------------------------------------------------------------------
	//                                       GET SCORES
	// -------------------------------------------------------------------------------------------
	
	/**
	 * Fetches a list of available scoreboards.
	 */
	public function getBoards() {
		
		return (makeCall("ScoreBoard.getBoards"): Call<GetBoardsResultData>);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       GET SCORES
	// -------------------------------------------------------------------------------------------
	
	/**
	 * Fetches a list of Score objects from a scoreboard. Use 'skip' and 'limit' for getting
	 * different pages.
	 * 
	 * @param id             The numeric ID of the scoreboard.
	 * @param limit          An integer indicating the number of scores to include in the list.
	 *                       Default = 10.
	 * @param skip           The time-frame to pull scores from (see notes for acceptable values).
	 * @param period         An integer indicating the number of scores to skip before starting the
	 *                       list. Default = 0.
	 * @param social         If set to true, only social scores will be loaded (scores by the user
	 *                       and their friends). This param will be ignored if there is no valid
	 *                       session id and the 'user' param is absent.
	 * @param tag            A tag to filter results by.
	 * @param user           A user's ID or name. If 'social' is true, this user and their friends
	 *                       will be included. Otherwise, only scores for this user will be loaded.
	 *                       If this param is missing and there is a valid session id, that user
	 *                       will be used by default.
	 * @param externalAppId  Leave blank unless you which to fetch from an separate app.
	 */
	public function getScores
	( id           :Int
	, limit        :Int     = 10
	, skip         :Int     = 0
	, period       :Period  = DAY
	, social       :Bool    = false
	, tag          :String  = null
	, user         :Dynamic = null
	, externalAppId:String  = null
	):Call<GetScoresResultData> {
		
		if (user != null && !Std.isOfType(user, String) && !Std.isOfType(user, Int))
			user = user.id;
		
		return (makeCall("ScoreBoard.getScores"): Call<GetScoresResultData>)
			.addComponentParameter("id"    , id    )
			.addComponentParameter("limit" , limit , 10)
			.addComponentParameter("skip"  , skip  , 0)
			.addComponentParameter("period", period, Period.DAY)
			.addComponentParameter("social", social, false)
			.addComponentParameter("tag"   , tag   , null)
			.addComponentParameter("user"  , user  , null)
			.addComponentParameter("app_id", externalAppId);
	}
	
	// -------------------------------------------------------------------------------------------
	//                                       POST SCORE
	// -------------------------------------------------------------------------------------------
	
	/**
	 * Posts a score to the specified scoreboard.
	 * 
	 * @param id     The numeric ID of the scoreboard.
	 * @param value  The value of the score.
	 * @param tag    An optional tag that can be used to filter scores via ScoreBoard.getScores
	 */
	public function postScore(id:Int, value:Int, tag:String = null):Call<PostScoreResultData> {
		
		return (makeCall("ScoreBoard.postScore", true, true): Call<PostScoreResultData>)
			.addComponentParameter("id"   , id)
			.addComponentParameter("value", value)
			.addComponentParameter("tag"  , tag  , null);
	}
}

@:forward(getBoards, getScores)
abstract ExternalScoreBoardComponent(ScoreBoardComponent) from ScoreBoardComponent {}