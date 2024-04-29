import funkin.api.CrashHandler;
import haxe.Exception;
import flixel.util.FlxColor;
import funkin.api.AudioManager;
import funkin.StatsDisplay;
import funkin.Camera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import lime.app.Future;
import funkin.templates.Menu;

class Game extends flixel.FlxGame {
	public static var instance(default, null):Game;
	public static var stats:StatsDisplay = new StatsDisplay();
	public static var camBG:Camera;
	public static var camState:Camera;
	public static var camHUD:Camera;
	public static var camOverlay:Camera;

	public function new(width:Int, height:Int) {
		if (instance != null)
			instance.close(true);
		super(width, height, StateManager, 144, 144, true, false);
		FlxG.cameras.cameraAdded.add((_) -> {
			removeChild(Game.stats);
			addChild(Game.stats);
		});
	}

	public function close(?message:String, ?restart:Bool = false) {
		if (message != null) {
			// handle the crash
		}
		// if (save.dirty)
	}
}

class StateManager extends flixel.FlxState {
	public static var curState:Menu;
	public static var curStateName:String = '';
	public static var lastState:Class<Menu>;
	public static var instance:StateManager;
	public static var bg:FlxSprite;
	public static var gradient:FlxSprite;
	public static var hue(default, set):Float = 0;
	public static var updateHue:Bool = true;

	public function new() {
		super();
		instance = this;

		FlxG.mouse.useSystemCursor = true;
		FlxG.fixedTimestep = false;
		FlxG.autoPause = false;

		FlxG.cameras.bgColor = 0x00000000;

		Game.camBG = new Camera();
		Game.camState = new Camera();
		Game.camHUD = new Camera();
		Game.camOverlay = new Camera();
		Game.camBG.antialiasing = true;
		Game.camState.antialiasing = true;
		Game.camHUD.antialiasing = true;
		Game.camOverlay.antialiasing = true;
		FlxG.cameras.reset(Game.camBG);
		FlxG.cameras.add(Game.camState, true);
		FlxG.cameras.add(Game.camHUD, false);
		FlxG.cameras.add(Game.camOverlay, false);

		bg = new FlxSprite().loadGraphic(funkin.api.FileManager.getImage('menuDesat', true));
		bg.screenCenter();
		bg.camera = Game.camBG;
		bg.active = false;
		add(bg);

		gradient = flixel.util.FlxGradient.createGradientFlxSprite(1, Std.int(bg.frameHeight + 400.), [FlxColor.TRANSPARENT, FlxColor.WHITE]);
		gradient.setGraphicSize(bg.frameWidth, bg.frameHeight + 400.);
		gradient.screenCenter();
		gradient.y -= 200.;
		gradient.blend = "multiply";
		gradient.camera = Game.camBG;
		gradient.active = false;
		add(gradient);

		instance.camera = Game.camState;

		funkin.api.Controls.init();
		open(new funkin.menus.MainMenu());
	}

	override function update(elapsed:Float) {
		if (hue >= 0 && updateHue)
			hue += elapsed * 16;
		if (gradient != null) {
			gradient.color = FlxColor.fromHSL(hue, 1, .5, 1);
			if (gradient.alpha < 1.)
				gradient.alpha += elapsed;
		}
		if (curState != null) {
			if (AudioManager.instrumental != null)
				funkin.api.Conductor.update(AudioManager.instrumental.time);
			curState.update(elapsed);
		}
	}

	public function open(newState:Menu, hueShift:Float = -1) {
		final newStateName:String = Type.getClassName(Type.getClass(newState));
		// fade it out and-
		remove(curState);
		if (curStateName != newStateName && curState != null) {
			curState.destroy();
			lastState = Type.getClass(curState);
			curState = null;
			if (hueShift >= 0)
				updateHue = true;
			else {
				updateHue = false;
				FlxTween.num(hue, hueShift, 1., null, (num:Float) -> hue = num);
			}
		}
		trace('[SM] Loading the state...');
		var pendingErrorMessage:Exception = null;
		final create = new Future<Void>(() -> {
			try
				newState.create()
			catch (fuck)
				pendingErrorMessage = fuck;
		}, true);
		create.onComplete((_) -> {
			add(newState);
			newState.camera = Game.camState;
			newState.active = false;
			curState = newState;
			curStateName = newStateName;
			trace('[SM] State loaded!');
			if (pendingErrorMessage != null)
				trace(pendingErrorMessage.details());
			return;
		});
	}

	public static function handleKeys(isKeybind:Bool, down:Bool, ?justPressed:Bool = false, name:String) { // ik its fucked up but it works to prevent some keys
		// trace('[INFO] $isKeybind $down $justPressed $name');
		if (isKeybind) {
			if (down && name == 'ACCEPT' && funkin.api.Controls.isKeyHeld('Alt'))
				return;
		} else {
			if (justPressed)
				switch name {
					#if FLX_DEBUG
					case 'F9':
						FlxG.debugger.visible = !FlxG.debugger.visible;
					#end
					case 'F11':
						FlxG.fullscreen = !FlxG.fullscreen;
				}
		}

		if (curState == null)
			return;

		if (down) {
			if (isKeybind)
				curState.onKeybindDown(justPressed, name);
			else
				curState.onKeyDown(justPressed, name);
		} else {
			if (isKeybind)
				curState.onKeybindUp(name);
			else
				curState.onKeyUp(name);
		}
	}

	static function set_hue(value:Float) {
		hue = value % 360.;
		return hue;
	}
}
