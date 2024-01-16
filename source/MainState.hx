import mint.ui.VolumeTray;
import backend.Controls;
import backend.MintFileManager;
import lime.app.Future;
import extendable.Menu;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import backend.AudioManager;
import mint.Camera;

class MainState extends FlxState {
	var gradient:FlxSprite;

	// var transition:FlxSprite;
	public var hue(default, set):Float = Math.random() * 359.;
	public var gradientAlpha(default, set) = 1.;

	static var updateBG:Bool = true;

	public static var instance:MainState;

	public var camBG:Camera;
	public var camState:Camera;
	public var camOverlay:Camera;

	public var curSubState(default, null):Menu;

	override function create() {
		camBG = new Camera();
		camBG.bgColor = 0x00000000;
		camBG.antialiasing = true;
		FlxG.cameras.reset(camBG);
		var bg = new FlxSprite().loadGraphic(MintFileManager.getImage('menuDesat', true));
		bg.screenCenter();
		bg.camera = camBG;
		add(bg);

		gradient = flixel.util.FlxGradient.createGradientFlxSprite(1, Std.int(bg.frameHeight + 400.), [FlxColor.TRANSPARENT, FlxColor.WHITE]);
		gradient.setGraphicSize(bg.frameWidth, bg.frameHeight + 400.);
		gradient.screenCenter();
		gradient.y -= 200.;
		gradient.blend = "multiply";
		gradient.camera = camBG;
		add(gradient);

		camState = new Camera();
		camState.bgColor = 0x00000000;
		camState.antialiasing = true;
		FlxG.cameras.add(camState, false);

		camOverlay = new Camera();
		camOverlay.bgColor = 0x00000000;
		camOverlay.antialiasing = true;
		FlxG.cameras.add(camOverlay, false);

		// transition = new FlxSprite(-3480, 0).loadGraphic(Paths.image('transition'));
		// transition.color = 0xFF000000;
		// transition.camera = camOverlay;
		// add(transition);

		persistentUpdate = true;
		instance = this;

		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;

		new backend.Controls();
		new VolumeTray();

		open(new menus.MainMenu());

		super.create();
	}

	override function update(elapsed:Float) {
		camBG.zoom = camState.zoom = camState.zoom + (1. - camState.zoom) * (elapsed * 8.);
		if (updateBG == true) {
			hue = (hue + elapsed * 32.);
			gradient.color = FlxColor.fromHSL(hue, 1., .5, 1.);
		}
		if (gradientAlpha != 1.) {
			gradientAlpha += elapsed;
			if (gradientAlpha > 1.)
				gradientAlpha = 1.;
		}

		if (curSubState != null) {
			curSubState.update(elapsed);
			var curBeat:Int = Math.floor((AudioManager.instrumental.time + AudioManager.offset) * .001 / AudioManager.crochet);
			// trace(AudioManager.instrumental.time, curBeat, AudioManager.beat);
			if (curBeat != AudioManager.beat) {
				AudioManager.beat = curBeat;
				if (curSubState != null)
					curSubState.onBeatHit(AudioManager.beat);
			}
		}

		super.update(elapsed);
	}

	public function open(the:Menu, hueShift:Float = -1.) {
		trace('switching menu: ' + Type.getClassName(Type.getClass(the)));
		if (hueShift == -1.)
			updateBG = true;
		else {
			updateBG = false;
			FlxTween.num(hue, hueShift, 1., null, (num:Float) -> hue = num);
		}
		if (curSubState != null) {
			// transition.x = -3480;
			// FlxTween.tween(transition, {x: -1100}, 1., {ease: FlxEase.quartOut});
			curSubState.onClose();
			FlxTween.tween(camState, {alpha: .0}, .7, {
				onComplete: (twn:FlxTween) -> {
					remove(curSubState);
					curSubState.camera = null;
					if (Type.getClassName(Type.getClass(curSubState)) != Type.getClassName(Type.getClass(the)))
						curSubState.destroy();
					var load:Future<Dynamic> = new Future(() -> the.create(), true);
					load.onComplete((wtf:Dynamic) -> {
						the.postCreate();
						// FlxTween.tween(transition, {x: 1280}, 1., {ease: FlxEase.quadOut});
						curSubState = the;
						curSubState.camera = camState;
					});
				}
			});
		} else {
			var load:Future<Dynamic> = new Future(() -> the.create(), true);
			load.onComplete((wtf:Dynamic) -> {
				the.postCreate();
				curSubState = the;
				curSubState.camera = camState;
			});
		}
	}

	public function onKeyDown(repeated:Bool, keybind:String, key:String) {
		// trace('Repeated: $repeated, Keybind: $keybind');

		switch keybind {
			case 'Volume_Down':
				VolumeTray.volume -= 5;
				return;
			case 'Volume_Up':
				VolumeTray.volume += 5;
				return;
			case 'Volume_Mute':
				VolumeTray.toggleMute();
				return;
		}

		if (curSubState != null)
			curSubState.onKeyDown(repeated, keybind, key);
	}

	public function onKeyUp(keybind:String, key:String) {
		if (curSubState != null)
			curSubState.onKeyUp(keybind, key);
	}

	function set_hue(value:Float) {
		hue = value % 360.;
		return hue;
	}

	function set_gradientAlpha(value:Float) {
		gradient.alpha = value;
		return gradientAlpha = value;
	}
}
