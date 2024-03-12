package menus;

import api.Cache;
import api.AudioManager;
import api.AudioManager.Conductor;
import api.MintFileManager;
import api.ChartParser;

class PlayState extends extendable.Menu {
	// var player1:Player;
	// var player2:Player;
	public static var difficulty:String;

	public function new(modName:String, songName:String, difficulty:String) {
		super();
		Cache.currentChart = MintFileManager.getChart('$songName-$difficulty');
		PlayState.difficulty = difficulty;
		MintFileManager.currentModFolder = modName;
	}

	override function create() {
		MainState.instance.noBeatCalc = true;
		AudioManager.loadSong('inst', 'vocals', difficulty, Cache.currentChart.initialBPM);
	}

	override function update(dt:Float) {}

	override function onBeatHit(curBeat:Int) {
		if (curBeat % 4 == 0) { // every section
			for (rawNote in Cache.currentChart.sections[Conductor.curSection + 2].notes) {
				
			}
		}
	}

	override function onKeyDown(repeated:Bool, keybind:String, key:String) {}

	override function onKeyUp(keybind:String, key:String) {}

	override function onClose() {
		PlayState.difficulty = null;
	}
}
