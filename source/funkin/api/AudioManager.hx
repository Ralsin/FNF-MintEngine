package funkin.api;

import haxe.Exception;
import flixel.FlxG;
import funkin.api.FileManager;
import openfl.utils.Future;
import flixel.sound.FlxSound;
import openfl.media.Sound;

typedef SoundsList = Map<String, {
	var path:String;
	var soundObject:FlxSound;
}>;

class AudioManager {
	public static var instrumental(default, null):FlxSound = new FlxSound();
	public static var vocals(default, null):FlxSound = new FlxSound();
	public static var opponentVocals(default, null):FlxSound = new FlxSound();
	public static var sounds(default, null):SoundsList = [];

	public static var offset:Int = 0;
	public static var curTrackName(default, null):String;

	public static var crotchet(default, null):Float = .6;
	public static var songBPM(default, set):Float = 100.;

	public static var songLoaded:Bool = false; // for PlayState

	var audioCache:Map<String, Sound> = [];

	public static function playMusic(name:String, bpm:Float, audioOffset:Int = 0, volume:Float = .5, looped:Bool = true) {
		if (curTrackName == name) {
			if (!instrumental.playing) {
				instrumental.fadeIn(1., 0., .5);
				songBPM = bpm;
				Conductor.curBPM = bpm;
				Conductor.invalidate();
			}
			return trace('[playMusic] name: $name, bpm: $bpm, offset: $audioOffset, looped: $looped');
		}
		if (instrumental != null && instrumental.playing) {
			flixel.tweens.FlxTween.tween(instrumental, {volume: 0.}, 1., {
				onComplete: (twn) -> {
					// instrumental.destroy();
					new Future<FlxSound>(() -> {
						// instrumental = FlxG.sound.load(MintFileManager.getMusic(name), 0., looped);
						instrumental.loadEmbedded(FileManager.getMusic(name));
						FlxG.sound.list.add(instrumental);
						instrumental.looped = true;
						instrumental.fadeIn(2. * (1. - instrumental.volume * 2.), 0., volume);
					}, true);
				}
			});
		} else {
			// instrumental = FlxG.sound.load(MintFileManager.getMusic(name), 0., looped);
			instrumental.loadEmbedded(FileManager.getMusic(name));
			FlxG.sound.list.add(instrumental);
			instrumental.looped = true;
			instrumental.fadeIn(2. * (1. - instrumental.volume * 2.), 0., volume);
		}
		curTrackName = name;
		songBPM = bpm;
		Conductor.curBPM = bpm;
		offset = audioOffset;
		trace('[playMusic] name: $name, bpm: $bpm, offset: $audioOffset, looped: $looped');
	}

	public static function loadSong(path:String, bpm:Float, audioOffset:Int = 0) {
		songLoaded = false;
		var songAudio = FileManager.getSong(path);
		if (songAudio.inst == null)
			throw new Exception('Song instrumental file wasn\'t found. Make sure its in the right folder and is called either "inst" or "instrumental".');
		instrumental.stop();
		vocals.stop();
		opponentVocals.stop();
		FlxG.sound.list.remove(instrumental);
		if (!songAudio.instExisted) {
			@:privateAccess if (instrumental._sound != null)
			instrumental._sound.close();
			instrumental.destroy();
			instrumental.looped = false;
		}
		instrumental = new FlxSound();
		instrumental.loadEmbedded(songAudio.inst);
		FlxG.sound.list.add(instrumental);
		if (songAudio.vocals != null) {
			FlxG.sound.list.remove(vocals);
			if (!songAudio.vocalsExisted) {
				@:privateAccess if (vocals._sound != null)
				vocals._sound.close();
				vocals.destroy();
			}
			vocals = new FlxSound();
			vocals.loadEmbedded(songAudio.vocals);
			vocals.looped = false;
			FlxG.sound.list.add(vocals);
		}
		if (songAudio.vocalsOpponent != null) {
			FlxG.sound.list.remove(opponentVocals);
			if (!songAudio.opponentVocalsExisted) {
				@:privateAccess if (opponentVocals._sound != null)
					opponentVocals._sound.close();
				opponentVocals.destroy();
			}
			opponentVocals = new FlxSound();
			opponentVocals.loadEmbedded(songAudio.vocalsOpponent);
			opponentVocals.looped = false;
			FlxG.sound.list.add(opponentVocals);
		}
		songBPM = bpm;
		Conductor.curBPM = bpm;
		offset = audioOffset;
		songLoaded = true;
	}

	public static function loadSound(tag:String, path:String, ignoreModsFolder:Bool = false):Void {
		var snd = sounds.get(tag);
		if (snd != null) {
			if (snd.path == path)
				return;
			snd.soundObject.destroy();
			// sounds.remove(tag); // it will be replaced after its loaded anyways
		}
		new Future<Void>(() -> {
			var sound:FlxSound = new FlxSound().loadEmbedded(FileManager.getSound(path, ignoreModsFolder));
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
		crotchet = 60. / value;
		return songBPM = value;
	}
}