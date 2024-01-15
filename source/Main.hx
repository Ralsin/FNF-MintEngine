package;
import mint.ui.external.FPS;
import mint.ui.external.Memory;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

class Main extends Sprite {
	public static var fpsVar:FPS;
	public static var ramVar:Memory;

	public static function main():Void {
		// Application.current.window.borderless = true;
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		addChild(new FlxGame(1280, 720, MainState, 144, 144, false, false));
		fpsVar = new FPS();
		ramVar = new Memory();
		addChild(fpsVar);
		addChild(ramVar);
		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, (event:openfl.events.UncaughtErrorEvent) -> {

		// });
	}
}