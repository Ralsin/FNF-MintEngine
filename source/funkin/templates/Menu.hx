package funkin.templates;

class Menu extends flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxObject> {
	public function preload() {}
	public function create() {}
	public function onStepHit(step:Int) {}
	public function onBeatHit(beat:Int) {}
	public function onKeyDown(justPressed:Bool, key:String) {}
	public function onKeyUp(key:String) {}
	public function onKeybindDown(justPressed:Bool, keybind:String) {}
	public function onKeybindUp(keybind:String) {}
	final public function open(newState:Menu, hue:Float = -1)
		Game.StateManager.instance.open(newState, hue);
}
