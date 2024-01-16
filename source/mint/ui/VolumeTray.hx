package mint.ui;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import backend.AudioManager;

class VolumeTray {
	public static var volume(default, set):Int = 100;
	public static var muted(default, null):Bool = false;
	static var mutedVolume:Int = 0; // to store the value after the mute
	static var tween:flixel.tweens.misc.VarTween;

	static final twoBars:Array<String> = ['█', '▄']; // full bar (10%) and half-bar (5%)

	static var canvas:FlxCamera; // not mint.Camera cuz it wont benefit
	static var volumeLabel:FlxText;
	static var volumeSlider:FlxText;

	public static function init() {
		if (canvas != null)
			return;

		canvas = new FlxCamera(16, 640, 202, 64);
		canvas.bgColor = 0x00000000;
		canvas.alpha = 0.;
		canvas.active = false;
		canvas.visible = false;
		FlxG.cameras.add(canvas, false);

		// var bg = new FlxSprite().makeGraphic(1, 1, 0x99111119);
		var bg = flixel.util.FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(202, 64, 0x00000000, true, 'VolumeTrayBGWorkaround'), 0., 0., 202., 64., 16., 16., 0xCC111115);
		bg.setGraphicSize(202., 64.);
		volumeLabel = new FlxText(8., 8., 186., 'Volume: 100%');
		volumeLabel.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		volumeLabel.borderSize = 2;
		volumeSlider = new FlxText(8., 32., 186., '█  █  █  █  █  █  █  █  █  █');
		volumeSlider.setFormat('assets/fonts/times.ttf', 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		volumeSlider.borderSize = 2;

		for (sprite in [bg, volumeLabel, volumeSlider]) {
			MainState.instance.add(sprite);
			sprite.camera = canvas;
		}

		AudioManager.loadSound('volumeChange', 'volume-change', true);
		volume = FlxG.save.data.volume;
		canvas.visible = true;
	}

	static function set_volume(v:Int) {
		if (canvas.visible == false) {
			FlxG.sound.volume = v * .01;
			return volume = v;
		}

		if (muted && v != -1) {
			muted = false;
			v = Std.int(Math.min(Math.max(cast mutedVolume + v, 0), 100));
		} else
			v = Std.int(Math.min(Math.max(v, 0), 100));

		if (volume == v)
			return v;

		volumeLabel.text = 'Volume: $v%';
		var sliderBars = '';
		for (i in 0...Std.int(v * .1))
			sliderBars += twoBars[0] + '  ';
		if (v % 10 > 4)
			sliderBars += twoBars[1];

		volumeSlider.text = StringTools.rtrim(sliderBars);

		if (tween != null)
			tween.cancel();

		canvas.alpha = 1.;
		canvas.active = true;

		tween = flixel.tweens.FlxTween.tween(canvas, {alpha: 0.}, .5, {
			startDelay: 1.,
			onComplete: (twn) -> {
				canvas.active = false;
			}
		});

		FlxG.save.data.volume = v;
		FlxG.save.flush();

		FlxG.sound.volume = v * .01;
		AudioManager.playSound('volumeChange', 1);
		return volume = v;
	}

	public static function toggleMute() {
		muted = !muted;
		if (muted) {
			mutedVolume = volume == 0 ? 75 : cast volume;
			volume = -1;
		} else
			volume = cast mutedVolume;
	}
}
