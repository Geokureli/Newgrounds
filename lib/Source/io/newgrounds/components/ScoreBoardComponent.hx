package io.newgrounds.components;

import io.newgrounds.objects.User;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result;
import io.newgrounds.objects.events.Result.ScoreBoardResult;
import io.newgrounds.objects.events.Result.GetScoresResult;
import io.newgrounds.NGLite;

import haxe.ds.IntMap;

class ScoreBoardComponent extends Component {
	
	public function new (core:NGLite){ super(core); }
	
	// -------------------------------------------------------------------------------------------
	//                                       GET SCORES
	// -------------------------------------------------------------------------------------------
	
	/**
	 * Fetches a list of available scoreboards.
	 */
	public function getBoards():Call<ScoreBoardResult> {
		
		return new Call<ScoreBoardResult>(_core, "ScoreBoard.getBoards");
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
	 */
	public function getScores
	( id           :Int
	, limit        :Int     = 10
	, skip         :Int     = 0
	, period       :Period  = DAY
	, social       :Bool    = false
	, tag          :String  = null
	, user         :Dynamic = null
	):Call<GetScoresResult> {
		
		if (user != null && !Std.isOfType(user, String) && !Std.isOfType(user, Int))
			user = user.id;
		
		return new Call<GetScoresResult>(_core, "ScoreBoard.getScores")
			.addComponentParameter("id"    , id    )
			.addComponentParameter("limit" , limit , 10)
			.addComponentParameter("skip"  , skip  , 0)
			.addComponentParameter("period", period, Period.DAY)
			.addComponentParameter("social", social, false)
			.addComponentParameter("tag"   , tag   , null)
			.addComponentParameter("user"  , user  , null);
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
	public function postScore(id:Int, value:Int, tag:String = null):Call<PostScoreResult> {
		
		return new Call<PostScoreResult>(_core, "ScoreBoard.postScore", true, true)
			.addComponentParameter("id"   , id)
			.addComponentParameter("value", value)
			.addComponentParameter("tag"  , tag  , null);
	}
}

enum abstract Period(String) to String from String {
	
	/** Indicates scores are from the current day. */
	var DAY = "D";
	/** Indicates scores are from the current week. */
	var WEEK = "W";
	/** Indicates scores are from the current month. */
	var MONTH = "M";
	/** Indicates scores are from the current year. */
	var YEAR = "Y";
	/** Indicates scores are from all-time. */
	var ALL = "A";
}
