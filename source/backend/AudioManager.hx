package backend;

import flixel.FlxG;
import backend.MintFileManager;
import openfl.utils.Future;
import flixel.sound.FlxSound;
import openfl.media.Sound;

typedef SoundsList = Map<String, {
	var path: String;
	var soundObject: FlxSound;
}>;

class AudioManager {
	public static var instrumental(default, null):FlxSound = new FlxSound();
	public static var vocals(default, null):FlxSound = new FlxSound();
	// public static var vocals2(default, null):FlxSound = new FlxSound();
	public static var sounds(default, null):SoundsList = [];

	public static var offset:Float = 0.;
	public static var curTrackName(default, null):String;

	public static var crochet(default, null):Float = .6;
	public static var songBPM(default, set):Float = 100.;
	@:allow(MainState.update) public static var beat(default, null):Int = -1;

	var audioCache:Map<String, Sound> = [];

	public static function playMusic(name:String, bpm:Float, audioOffset:Float = 0., volume:Float = .5, looped:Bool = true) {
		if (curTrackName == name)
			return trace('[playMusic] name: $name, bpm: $bpm, offset: $audioOffset, looped: $looped');
		if (instrumental != null && instrumental.playing) {
			flixel.tweens.FlxTween.tween(instrumental, {volume: 0.}, 1., {
				onComplete: (twn) -> {
					// instrumental.destroy();
					new Future<FlxSound>(() -> {
						// instrumental = FlxG.sound.load(MintFileManager.getMusic(name), 0., looped);
						instrumental.loadEmbedded(MintFileManager.getMusic(name));
						FlxG.sound.list.add(instrumental);
						instrumental.looped = true;
						instrumental.fadeIn(2. * (1. - instrumental.volume * 2.), 0., volume);
					}, true);
				}
			});
		} else {
			// instrumental = FlxG.sound.load(MintFileManager.getMusic(name), 0., looped);
			instrumental.loadEmbedded(MintFileManager.getMusic(name));
			FlxG.sound.list.add(instrumental);
			instrumental.looped = true;
			instrumental.fadeIn(2. * (1. - instrumental.volume * 2.), 0., volume);
		}
		curTrackName = name;
		songBPM = bpm;
		beat = 0;
		offset = audioOffset;
		trace('[playMusic] name: $name, bpm: $bpm, offset: $audioOffset, looped: $looped');
	}
	public static function loadSong(inst:String, vocal:String, difficulty:String, bpm:Float, audioOffset:Float = 0.) {
		// var instrumentals:Sound = audioCache.get(inst);
		// var thevoicesinmyhead:Sound = audioCache.get(vocal);
		// if (instrumentals != null)
		// 	instrumental.loadEmbedded(instrumentals);
		// if (thevoicesinmyhead != null)
		// 	instrumental.loadEmbedded(thevoicesinmyhead);

		var songAudio = MintFileManager.getSong(inst, vocal, difficulty);
		// audioCache.set(inst, songAudio.inst);
		instrumental.loadEmbedded(songAudio.inst);
		FlxG.sound.list.add(instrumental);
		if (songAudio.hasVocals) {
			vocals.loadEmbedded(songAudio.vocals);
			FlxG.sound.list.add(vocals);
		}
		songBPM = bpm;
		beat = 0;
		offset = audioOffset;
	}

	public static function loadSound(tag:String, path:String, ignoreModsFolder:Bool = false):Void {
		var snd = sounds.get(tag);
		if (snd != null) {
			if (snd.path == path)
				return;
			snd.soundObject.destroy();
			// sounds.remove(tag); // it will be replaced after its loaded anyways
		}
		new Future<Void>(()->{
			var sound:FlxSound = new FlxSound().loadEmbedded(MintFileManager.getSound(path, ignoreModsFolder));
			FlxG.sound.list.add(sound);
			sounds.set(tag, {path: path, soundObject: sound});
		}, true);
	}

	public static function playSound(tag:String, volume:Float = .5, startTime:Float = 0, forceRestart:Bool = true) {
		if (sounds.get(tag) == null)
			return;
		var sound:FlxSound = sounds.get(tag).soundObject;
		sound.volume = volume;
		sound.play(forceRestart, startTime);
	}

	// public static function clear() {
	// 	// var collection:Array<FlxSound> = [instrumental, vocals];
	// 	// for (sound in sounds) {
	// 	// 	collection.push(sound);
	// 	// }
	// 	// @:privateAccess for (sound in collection)
	// 	// 	sound._sound.__buffer = null;
	// 	for (key in audioCache.keys())
	// 		Assets.cache.audio.remove(key);
	// }

	static function set_songBPM(value:Float) {
		crochet = 60. / value;
		return songBPM = value;
	}
}
