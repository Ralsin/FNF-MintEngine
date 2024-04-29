package funkin.menus;

import funkin.api.Conductor;
import funkin.api.ChartProcessor;
import funkin.api.AudioManager;
import funkin.api.FileManager;
import funkin.api.Cache;
import funkin.objects.StrumLine;
import funkin.objects.Note;

class PlayState extends funkin.templates.Menu {
	public static var instance(default, null):PlayState;

	public var playerStrums(default, null):Array<StrumLine>;
	public var opponentStrums(default, null):Array<StrumLine>;
	public var allStrums(default, null):Array<StrumLine>;

	public var chartData(default, null):ChartData;
	public var songName(default, null):String;
	public var difficulty(default, null):String;

	public var keyCount(default, null):Int = 4;

	public function new(songName:String, difficulty:String) {
		super();
		FileManager.modFolder = 'test';
		this.songName = songName;
		this.difficulty = difficulty;
	}

	override function create() {
		instance = this;

		chartData = FileManager.getChart(songName, difficulty);

		playerStrums = [];
		opponentStrums = [];
		allStrums = [];
		keyCount = chartData.keyCount;
		for (i in 0...keyCount) {
			final strum = new StrumLine(i);
			strum.receptor.x = strum.receptor.width * (i - keyCount * .5) + flixel.FlxG.width * .25;
			strum.receptor.y = 48;
			opponentStrums.push(strum);
			allStrums.push(strum);
			add(strum.receptor);
		}
		for (i in 0...keyCount) {
			final strum = new StrumLine(i);
			strum.receptor.x = strum.receptor.width * (i - keyCount * .5) + flixel.FlxG.width * .75;
			strum.receptor.y = 48;
			playerStrums.push(strum);
			allStrums.push(strum);
			add(strum.receptor);
		}
		AudioManager.loadSong('gayfreaker', 152);
		for (i in 0...3) {
			final notes = chartData.sections[i].notes;
			notes.sort((a, b) -> return Math.floor(a.strumTime * 1000000 - b.strumTime * 1000000));
			for (note in notes) {
				final leNote = new NoteSprite(note.dir < keyCount ? note.dir : note.dir - keyCount, note.strumTime, note.length, note.type);
				allStrums[note.dir].notes.add(leNote);
				add(leNote);
				if (leNote.sustain != null)
					add(leNote.sustain);
			}
		}
		AudioManager.instrumental.play();
		AudioManager.vocals.play();
		AudioManager.opponentVocals.play();
	}

	override function update(elapsed:Float) {
		if (!AudioManager.songLoaded)
			return;
		for (strum in allStrums) {
			strum.receptor.update(elapsed);
			strum.notes.forEachExists((note) -> {
				final positionScale:Float = note.reference.strumTime - Conductor.songPosition * 1000;
				note.x = strum.receptor.x;
				note.y = strum.receptor.y + (positionScale * chartData.speed) * .45;
				if (positionScale < -.1 && (note.y < -100 || note.y > flixel.FlxG.height + 100 || note.x < 100 || note.x > flixel.FlxG.width + 100)) {
					strum.notes.remove(note);
					note.destroy();
				}
				note.update(elapsed);
			});
		}
		Game.camBG.zoom = camera.zoom = camera.zoom + (1. - camera.zoom) * Math.min(elapsed * 8., 1.);
	}

	override function onKeybindDown(justPressed:Bool, keybind:String) {
		if (!justPressed)
			return;

		switch keybind {
			case 'Back':
				// open(Type.createInstance(Game.StateManager.lastState, []));
				open(new funkin.menus.MainMenu());

			case 'Left':
				playerStrums[0].receptor.animation.play('ghosted');
				playerStrums[0].receptor.centerOffsets();
			case 'Down':
				playerStrums[1].receptor.animation.play('ghosted');
				playerStrums[1].receptor.centerOffsets();
			case 'Up':
				playerStrums[2].receptor.animation.play('ghosted');
				playerStrums[2].receptor.centerOffsets();
			case 'Right':
				playerStrums[3].receptor.animation.play('ghosted');
				playerStrums[3].receptor.centerOffsets();
		}
	}

	override function onKeybindUp(keybind:String) {
		switch keybind {
			case 'Left':
				playerStrums[0].receptor.animation.play('idle');
				playerStrums[0].receptor.centerOffsets();
			case 'Down':
				playerStrums[1].receptor.animation.play('idle');
				playerStrums[1].receptor.centerOffsets();
			case 'Up':
				playerStrums[2].receptor.animation.play('idle');
				playerStrums[2].receptor.centerOffsets();
			case 'Right':
				playerStrums[3].receptor.animation.play('idle');
				playerStrums[3].receptor.centerOffsets();
		}
	}

	override function onKeyDown(justPressed:Bool, key:String) {
		switch key {
			case 'K':
				AudioManager.instrumental.volume = 0;
			case 'L':
				AudioManager.instrumental.volume = 1;
			case 'N':
				AudioManager.vocals.volume = 0;
			case 'M':
				AudioManager.vocals.volume = 1;
		}
	}

	override function onBeatHit(beat:Int) {
		AudioManager.opponentVocals.time = AudioManager.vocals.time = AudioManager.instrumental.time;
		if (beat % 4 == 0) {
			final curSection:Int = Math.floor(beat / 4);
			// new lime.app.Future<Void>(() -> {
				final notes = chartData.sections[curSection + 4].notes;
				notes.sort((a, b) -> return Math.floor(a.strumTime * 1000000 - b.strumTime * 1000000));
				for (note in notes) {
					final leNote = new NoteSprite(note.dir < keyCount ? note.dir : note.dir - keyCount, note.strumTime, note.length, note.type);
					allStrums[note.dir].notes.add(leNote);
					add(leNote);
					if (leNote.sustain != null)
						add(leNote.sustain);
				}
			// }, true);
		}
		
		if (beat % 4 == 0) {
			Game.StateManager.gradient.alpha = .8;
			camera.zoom += .01;
		}
		camera.zoom += .01;
	}

	override function destroy() {

	}
}
