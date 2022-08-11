package io.newgrounds.components;
class ComponentList {
	
	var _core:NGLite;
	
	/** Used to get and validate information associated with your app, including user sessions. */
	public var app       : AppComponent;
	/** Handles loading and saving of game states. */
	public var cloudSave : CloudSaveComponent;
	/** Handles logging of custom events. */
	public var event     : EventComponent;
	/** Provides information about the gateway server. */
	public var gateway   : GatewayComponent;
	/** This class handles loading various URLs and tracking referral stats. */
	public var loader    : LoaderComponent;
	/** Handles loading and unlocking of medals. */
	public var medal     : MedalComponent;
	/** Handles loading and posting of high scores and scoreboards. */
	public var scoreBoard: ScoreBoardComponent;
	
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
