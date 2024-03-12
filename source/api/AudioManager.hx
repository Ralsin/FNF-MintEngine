package api;

import api.ChartParser.BPMChange;
import flixel.FlxG;
import api.MintFileManager;
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
		Conductor.curBPM = bpm;
		offset = audioOffset;
		trace('[playMusic] name: $name, bpm: $bpm, offset: $audioOffset, looped: $looped');
	}

	public static function loadSong(inst:String, vocal:String, difficulty:String, bpm:Float, audioOffset:Int = 0) {
		var songAudio = MintFileManager.getSong(inst, vocal, difficulty);
		instrumental.loadEmbedded(songAudio.inst);
		FlxG.sound.list.add(instrumental);
		if (songAudio.hasVocals) {
			vocals.loadEmbedded(songAudio.vocals);
			FlxG.sound.list.add(vocals);
		}
		songBPM = bpm;
		Conductor.curBPM = bpm;
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
		new Future<Void>(() -> {
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
		crotchet = 60. / value;
		return songBPM = value;
	}
}

class Conductor {
	public static var curStep(default, null):Int = 0;
	public static var curBeat(default, null):Int = 0;
	public static var curSection(default, null):Int = 0;
	public static var curPreciseStep(default, null):Float = 0.;
	public static var curPreciseBeat(default, null):Float = 0.;
	public static var curPreciseSection(default, null):Float = 0.;

	public static var experimental:Bool = false;
	public static var curBPM(default, set):Float;
	public static var curCrotchet(default, null):Float;
	private static var lastTime:Float;

	public static function getPreciseStepAt(time:Float):Float {
		return getPreciseBeatAt(time) * 4.;
	}

	public static function getStepAt(time:Float):Int {
		return Math.floor(getPreciseStepAt(time));
	}

	public static function getPreciseBeatAt(time:Float, ?bpm:Float):Float {
		var beat = 0.;
		var bpmChanges:Array<BPMChange> = [];
		var curCrotchet:Float = bpm == null ? AudioManager.crotchet : 60. / bpm;
		if (Cache.currentChart != null) {
			if (Cache.currentChart.bpmChanges.length > 0)
				bpmChanges = Cache.currentChart.bpmChanges.copy();
			curCrotchet = 60. / Cache.currentChart.initialBPM;
		}
		if (bpmChanges.length > 0)
			while (time - curCrotchet > 0.) {
				time -= curCrotchet;
				beat += 1.;
				if (bpmChanges.length > 0 && beat % 4. == 0. && bpmChanges[0].section == beat % 4.)
					curCrotchet = bpmChanges.shift().crotchet;
			}
		else
			while (time - curCrotchet > 0.) {
				time -= curCrotchet;
				beat += 1.;
			}
		beat += time / curCrotchet;
		return beat;
	}

	public static function getBeatAt(time:Float):Int {
		return Math.floor(getPreciseBeatAt(time));
	}

	public static function getPreciseSectionAt(time:Float):Float {
		return getPreciseBeatAt(time) * .25;
	}

	public static function getSectionAt(time:Float):Int {
		return Math.floor(getPreciseSectionAt(time));
	}

	public static function getSectionBPM(sectionIndex:Int, ?lastCheckedSection:Int):Float {
		var bpmChanges:Array<BPMChange> = [];
		if (Cache.currentChart != null) {
			if (Cache.currentChart.bpmChanges.length > 0)
				bpmChanges = Cache.currentChart.bpmChanges;
		}
		var lastBPM:Float = lastCheckedSection == null ? AudioManager.songBPM : curBPM;
		if (bpmChanges.length > 0) {
			for (i in 0...bpmChanges.length)
				if (bpmChanges[i].section < lastCheckedSection)
					continue;
				else if (bpmChanges[i].section <= sectionIndex)
					lastBPM = bpmChanges[i].bpm;
				else
					break;
		}
		return lastBPM;
	}

	public static function update(time:Float) {
		time = (time + AudioManager.offset) * .001;
		if (experimental) {
			curPreciseBeat += (time - lastTime) / curCrotchet;
			lastTime = time;
		} else
			curPreciseBeat = getPreciseBeatAt(time);

		curPreciseStep = curPreciseBeat * 4.;
		curPreciseSection = curPreciseBeat * .25;
		var newStep = Math.floor(curPreciseStep);
		var newBeat = Math.floor(curPreciseBeat);
		var newSection = Math.floor(curPreciseSection);
		if (newStep != curStep) {
			curStep = newStep;
			MainState.instance.state.onStepHit(curStep);
			// trace('Step: $curStep');
		}
		if (newBeat != curBeat) {
			curBeat = newBeat;
			MainState.instance.state.onBeatHit(curBeat);
			// trace('Beat: $curBeat');
		}
		if (newSection != curSection) {
			curBPM = getSectionBPM(newSection, curSection);
			curSection = newSection;
		}
	}

	public static function invalidate() { // in case you use experimental and beat calculation fucks up after rewind
		lastTime = 0;
		curPreciseBeat = 0;
		curSection = 0;
	}

	static function set_curBPM(newBPM:Float) {
		curCrotchet = 60. / newBPM;
		return curBPM = newBPM;
	}
}
