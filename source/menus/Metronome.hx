package menus;

import flixel.math.FlxRect;
import mint.ui.ScreenLog;
import api.AudioManager;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;

class Metronome extends extendable.Menu {
	var metronomeBG:FlxSprite;
	var dots:Array<FlxSprite> = [];
	var beatBar:FlxSprite;
	var sectionBar:FlxSprite;
	var timer:Float = 0.;
	var lastBeat:Int = 0;

	override function create() {
		AudioManager.instrumental.fadeOut(1., 0., (_) -> AudioManager.instrumental.pause());
		AudioManager.loadSound('metronome1', 'metronome1');
		AudioManager.loadSound('metronome2', 'metronome2');

		metronomeBG = new FlxSprite(100., 256.).makeGraphic(1, 1);
		metronomeBG.setGraphicSize(1080, 128);
		metronomeBG.updateHitbox();
		metronomeBG.alpha = .85;
		metronomeBG.color = 0x111119;
		add(metronomeBG);

		for (i in 0...9) {
			var dot = new FlxSprite(640., 312.).makeGraphic(16, 16);
			// dot.setGraphicSize(16., 16.);
			dot.angle = 45.;
			dot.updateHitbox();
			dot.offset.x = 0;
			dots[i] = dot;
			add(dot);
		}
		dots[0].clipRect = new FlxRect(0., 0., 16., 16.);
		dots[8].clipRect = new FlxRect(0., 0., 16., 16.);

		var beatBarUnderlay = new FlxSprite(112., 400.).makeGraphic(1, 1);
		beatBarUnderlay.setGraphicSize(128, 8);
		beatBarUnderlay.alpha = .25;
		beatBarUnderlay.active = false;
		beatBarUnderlay.updateHitbox();
		add(beatBarUnderlay);

		var sectionBarUnderlay = new FlxSprite(112., 432.).makeGraphic(1, 1);
		sectionBarUnderlay.setGraphicSize(128, 8);
		sectionBarUnderlay.alpha = .25;
		sectionBarUnderlay.active = false;
		sectionBarUnderlay.updateHitbox();
		add(sectionBarUnderlay);

		beatBar = new FlxSprite(112., 400.).makeGraphic(1, 1);
		beatBar.setGraphicSize(0.01, 8);
		beatBar.updateHitbox();
		add(beatBar);

		sectionBar = new FlxSprite(112., 432.).makeGraphic(1, 1);
		sectionBar.setGraphicSize(0.01, 8);
		sectionBar.updateHitbox();
		add(sectionBar);

		var sticc:FlxSprite = new FlxSprite(638., 240.).makeGraphic(1, 1);
		sticc.setGraphicSize(4., 160.);
		sticc.active = false;
		sticc.updateHitbox();
		add(sticc);

		var centerDot:FlxSprite = new FlxSprite(640., 312.).makeGraphic(1, 1);
		centerDot.setGraphicSize(16., 16.);
		centerDot.active = false;
		centerDot.angle = 45.;
		centerDot.updateHitbox();
		centerDot.offset.x = 0;
		add(centerDot);

		timer = 0.;
		lastBeat = 0;
	}

	override function update(elapsed:Float) {
		var beat = Conductor.getPreciseBeatAt(timer += elapsed, 90.);

		// dot.x = 640. - (beat % 1) * 128.;
		// dot.updateHitbox();
		for (i in 0...dots.length)
			dots[i].x = 640. - (beat % 1) * 128. + 128. * (i - 5);
		final dot1:FlxSprite = dots[0];
		final dot2:FlxSprite = dots[8];
		dot1.clipRect.x = Math.max(dot1.x - metronomeBG.x, 0.);
		dot1.clipRect = dot1.clipRect;
		dot2.clipRect.width = Math.min((dot2.x + dot2.width) - (metronomeBG.x + metronomeBG.width), dot2.frameWidth);
		dot2.clipRect = dot2.clipRect;

		beatBar.setGraphicSize(128. - 127.99 * (beat % 1), 8);
		beatBar.updateHitbox();
		sectionBar.setGraphicSize(128. - 127.99 * ((beat * .25) % 1), 8);
		sectionBar.updateHitbox();

		var fbeat = Math.floor(beat);
		if (fbeat > lastBeat) {
			if (fbeat % 4 == 0)
				AudioManager.playSound('metronome2');
			else
				AudioManager.playSound('metronome1');
			lastBeat = fbeat;
			trace(fbeat);
		}
		super.update(elapsed);
	}

	// override function onKeybindDown(keybind:String, repeated:Bool) {}

	override function onKeybindUp(keybind:String) {
		if (keybind == "Back")
			open(new MainMenu());
	}

	override function onKeyDown(key:String, repeated:Bool) {
		if (key == "P") {
			Conductor.experimental = !Conductor.experimental;
			ScreenLog.log('Switched experimental beat calculation to "${Conductor.experimental}".');
		}
	}
}
