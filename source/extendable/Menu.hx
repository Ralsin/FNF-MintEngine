package extendable;

class Menu extends flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxBasic> {
	public function new() {
		super();
		active = false;
	}

	public function create() {}

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

	public function onStepHit(curStep:Int) {}

	public function onBeatHit(curBeat:Int) {}

	public function onKeybindDown(keybind:String, repeated:Bool) {}

	public function onKeybindUp(keybind:String) {}

	public function onKeyDown(key:String, repeated:Bool) {}

	public function onKeyUp(key:String) {}

	/*** Switches the menu. Shortcut to `MainState.instance.open`. */
	function open(the:Menu, hueShift:Float = -1.)
		MainState.instance.open(the, hueShift);
}
