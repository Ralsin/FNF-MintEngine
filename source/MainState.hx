import lime.app.Future;
import extendable.Menu;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import api.AudioManager;
import mint.Camera;
import api.Controls;
import api.MintFileManager;
import mint.ui.VolumeTray;

class MainState extends FlxState {
	public static var instance:MainState;

	var gradient:FlxSprite;

	public var hue(default, set):Float = Math.random() * 359.;
	public var gradientAlpha(default, set) = 1.;

	static var updateBG:Bool = true;

	public var camBG:Camera;
	public var camState:Camera;
	public var camOverlay:Camera;

	public var state(default, null):Menu;
	public var stateStr(default, null):String;
	public var stateTween:FlxTween;

	override function create() {
		camBG = new Camera();
		camBG.bgColor = 0x00000000;
		camBG.antialiasing = true;
		FlxG.cameras.reset(camBG);

		var bg = new FlxSprite().loadGraphic(MintFileManager.getImage('menuDesat', true));
		bg.screenCenter();
		bg.camera = camBG;
		bg.active = false;
		add(bg);

		gradient = flixel.util.FlxGradient.createGradientFlxSprite(1, Std.int(bg.frameHeight + 400.), [FlxColor.TRANSPARENT, FlxColor.WHITE]);
		gradient.setGraphicSize(bg.frameWidth, bg.frameHeight + 400.);
		gradient.screenCenter();
		gradient.y -= 200.;
		gradient.blend = "multiply";
		gradient.camera = camBG;
		gradient.active = false;
		add(gradient);

		camState = new Camera();
		camState.bgColor = 0xCC111115;
		camState.antialiasing = true;
		camState.filters = [new openfl.filters.ShaderFilter(new flixel.addons.display.FlxRuntimeShader(null, '
			#pragma header
			void main() {
				#pragma body
				gl_Position = openfl_Matrix * openfl_Position * mat4(.5, .1, 0., -.35, .1, 1., 0., 0., 0., 0., 0., 0., .65, -.1, 0., 1.5);
			}
		'))];
		FlxG.cameras.add(camState, false);

		camOverlay = new Camera();
		camOverlay.bgColor = 0x00000000;
		camOverlay.antialiasing = true;
		FlxG.cameras.add(camOverlay, false);

		persistentUpdate = true;
		instance = this;

		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;

		api.Controls.init();
		VolumeTray.init();

		open(new menus.MainMenu());

		super.create();
	}

	override function update(elapsed:Float) {
		Controls.update(elapsed);
		if (updateBG == true) {
			hue = (hue + elapsed * 32.);
			gradient.color = FlxColor.fromHSL(hue, 1., .5, 1.);
		}
		if (gradientAlpha != 1.) {
			gradientAlpha += elapsed;
			if (gradientAlpha > 1.)
				gradientAlpha = 1.;
		}

		if (state != null) {
			Conductor.update(AudioManager.instrumental.time);
			state.update(elapsed);
		}
		camBG.zoom = camState.zoom = camState.zoom + (1. - camState.zoom) * (elapsed * 8.);

		super.update(elapsed);
	}

	public function open(the:Menu, hueShift:Float = -1.) {
		var nextStateStr:String = Type.getClassName(Type.getClass(the));
		trace('switching menu: ' + nextStateStr);

		if (hueShift == -1.)
			updateBG = true;
		else {
			updateBG = false;
			FlxTween.num(hue, hueShift, 1., null, (num:Float) -> hue = num);
		}
		if (state != null) {
			state.onClose();
			FlxTween.tween(camState, {alpha: .0}, .7, {
				onComplete: (twn:FlxTween) -> {
					remove(state);
					state.camera = null;
					if (Type.getClassName(Type.getClass(state)) != nextStateStr)
						state.destroy();

					var load:Future<Dynamic> = new Future(() -> the.create(), true);
					load.onComplete((wtf:Dynamic) -> {
						state = the;
						stateStr = nextStateStr;
						state.camera = camState;
						MainState.instance.add(state);
						flixel.tweens.FlxTween.tween(state.camera, {alpha: 1.}, .7, {onComplete: (_) -> state.onOpen()});
					});
				}
			});
		} else {
			var load:Future<Dynamic> = new Future(() -> the.create(), true);
			load.onComplete((wtf:Dynamic) -> {
				state = the;
				stateStr = nextStateStr;
				state.camera = camState;
				MainState.instance.add(state);
				flixel.tweens.FlxTween.tween(state.camera, {alpha: 1.}, .7, {onComplete: (_) -> state.onOpen()});
			});
		}
	}

	public function onKeybindDown(keybind:String, autorepeat:Bool) {
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
		if (state != null)
			state.onKeybindDown(keybind, autorepeat);
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
