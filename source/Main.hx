import lime.app.Application;
import flixel.FlxG;
import mint.ui.external.CrashHandler;
import mint.ui.external.StatsDisplay;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

class Main extends Sprite {
	public static var instance(default, null):Main;
	public static var statsLabel:StatsDisplay;

	public static function main():Void {
		#if (hl && release)
		hl.UI.closeConsole();
		#end
		Lib.current.addChild(instance = new Main());
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

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, (event:openfl.events.UncaughtErrorEvent) -> {
			var emsg = '';
			for (line in CrashHandler.getFilePos(cast haxe.CallStack.exceptionStack(true)))
				emsg += line;
			CrashHandler.errorPopup(event.error+'\n'+emsg);
		});
		addChild(new FlxGame(1280, 720, MainState, 60, 60, false, false));
		FlxG.sound.volume = (api.SaveManager.save.data.volume ??= mint.ui.VolumeTray.volume) * .01;
		addChild(statsLabel = new StatsDisplay());
		addChild(mint.ui.ScreenLog.display);
	}
}