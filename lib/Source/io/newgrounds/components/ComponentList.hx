package io.newgrounds.components;

import io.newgrounds.components.app.AppComponent;
import io.newgrounds.components.cloud.CloudSaveComponent;
import io.newgrounds.components.event.EventComponent;
import io.newgrounds.components.gateway.GatewayComponent;
import io.newgrounds.components.loader.LoaderComponent;
import io.newgrounds.components.medal.MedalComponent;
import io.newgrounds.components.score.ScoreBoardComponent;

class ComponentList {
	
	var _core:NGLite;
	
	/** Used to get and validate information associated with your app, including user sessions. */
	public final app       : AppComponent;
	/** Handles loading and saving of game states. */
	public final cloudSave : CloudSaveComponent;
	/** Handles logging of custom events. */
	public final event     : EventComponent;
	/** Provides information about the gateway server. */
	public final gateway   : GatewayComponent;
	/** This class handles loading various URLs and tracking referral stats. */
	public final loader    : LoaderComponent;
	/** Handles loading and unlocking of medals. */
	public final medal     : MedalComponent;
	/** Handles loading and posting of high scores and scoreboards. */
	public final scoreBoard: ScoreBoardComponent;
	
	public function new(core:NGLite) {
		
		_core = core;
		
		app        = new AppComponent       (_core);
		cloudSave  = new CloudSaveComponent (_core);
		event      = new EventComponent     (_core);
		gateway    = new GatewayComponent   (_core);
		loader     = new LoaderComponent    (_core);
		medal      = new MedalComponent     (_core);
		scoreBoard = new ScoreBoardComponent(_core);
	}
}
