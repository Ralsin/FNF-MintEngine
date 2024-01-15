package extendable;

class Menu extends flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxBasic> {
	// var controls = backend.PlayerSettings.player1.controls;

	public function new() {
		super();
		active = false;
	}

	public function create() {}

	public final function postCreate() {
		camera = MainState.instance.camState;
		MainState.instance.add(this);
		flixel.tweens.FlxTween.tween(camera, {alpha: 1.}, .7, {onComplete: (twn) -> onOpen()});
	}
	/**
	 * Function that is run after the state was loaded and shown, after the transition is complete.
	 * Override to add functionality.
	 */
	public function onOpen() {}

	/**
	 * Function that is run before the state closes and while transition is active.
	 * Override to add functionality.
	 */
	public function onClose() {}

	public function onBeatHit(curBeat:Int) {}

	public function onKeyDown(isSpam:Bool, keybind:String, key:String) {}

	public function onKeyUp(keybind:String, key:String) {}

	/**
	 * Switches the menu. Shortcut to `MainState.instance.open`.
	 */
	function open(the:Menu, hueShift:Float = -1.)
		MainState.instance.open(the, hueShift);
}
