package funkin.api;

import funkin.menus.PlayState;
import Game.StateManager;

typedef BPMChange = {
	var section:Int;
	var bpm:Float;
	var crotchet:Float;
};

class Conductor {
	public static var curStep(default, null):Int = 0;
	public static var curBeat(default, null):Int = 0;
	public static var curSection(default, null):Int = 0;
	public static var curPreciseStep(default, null):Float = 0.;
	public static var curPreciseBeat(default, null):Float = 0.;
	public static var curPreciseSection(default, null):Float = 0.;

	public static var songPosition(default, null):Float = 0.;

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
		if (PlayState.instance != null && PlayState.instance.chartData != null) {
			if (PlayState.instance.chartData.bpmChanges != null && PlayState.instance.chartData.bpmChanges.length > 0)
				bpmChanges = PlayState.instance.chartData.bpmChanges.copy();
			curCrotchet = 60. / PlayState.instance.chartData.initialBPM;
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
		if (PlayState.instance != null && PlayState.instance.chartData != null) {
			if (PlayState.instance.chartData.bpmChanges != null && PlayState.instance.chartData.bpmChanges.length > 0)
				bpmChanges = PlayState.instance.chartData.bpmChanges;
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
		songPosition = songPosition + (time - songPosition) * Math.min(flixel.FlxG.elapsed * 16, 1);
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
			StateManager.curState.onStepHit(curStep);
			// trace('Step: $curStep');
		}
		if (newBeat != curBeat) {
			curBeat = newBeat;
			StateManager.curState.onBeatHit(curBeat);
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
