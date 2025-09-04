package io.newgrounds.components;

import io.newgrounds.components.AppComponent;
import io.newgrounds.components.CloudSaveComponent;
import io.newgrounds.components.EventComponent;
import io.newgrounds.components.GatewayComponent;
import io.newgrounds.components.LoaderComponent;
import io.newgrounds.components.MedalComponent;
import io.newgrounds.components.ScoreBoardComponent;

class ComponentList {
	
	/** Used to get and validate information associated with your app, including user sessions. */
	public final app    : AppComponent;
	
	/** Handles loading and saving of game states. */
	public final cloudSave : CloudSaveComponent;
	
	/** Handles logging of custom events. */
	public final event  : EventComponent;
	
	/** Provides information about the gateway server. */
	public final gateway: GatewayComponent;
	
	/** This class handles loading various URLs and tracking referral stats. */
	public final loader : LoaderComponent;
	
	/** Handles loading and unlocking of medals. */
	public final medal     : MedalComponent;
	
	/** Handles loading and posting of high scores and scoreboards. */
	public final scoreBoard: ScoreBoardComponent;
	
	public function new(core:BaseCore) {
		
		app        = new AppComponent       (core);
		cloudSave  = new CloudSaveComponent (core);
		event      = new EventComponent     (core);
		gateway    = new GatewayComponent   (core);
		loader     = new LoaderComponent    (core);
		medal      = new MedalComponent     (core);
		scoreBoard = new ScoreBoardComponent(core);
	}
}

abstract ExternalComponentList(ComponentList) {
	
	/** Handles loading and saving of game states. */
	public var cloudSave (get, never):ExternalCloudSaveComponent;
	inline function get_cloudSave() return this.cloudSave;
	
	/** Handles loading and unlocking of medals. */
	public var medal     (get, never):ExternalMedalComponent;
	inline function get_medal() return this.medal;
	
	/** Handles loading and posting of high scores and scoreboards. */
	public var scoreBoard(get, never):ExternalScoreBoardComponent;
	inline function get_scoreBoard() return this.scoreBoard;
	
	public function new(core:BaseCore) {
		
		this = new ComponentList(core);
	}
}
