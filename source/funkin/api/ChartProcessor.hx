package funkin.api;

import funkin.api.Conductor.BPMChange;

typedef ChartData = {
	var sections:Array<SectionData>;
	var events:Array<EventData>;
	var initialBPM:Float;
	var initialPlayer:String;
	var initialOpponent:String;
	var noteskin:String;
	var gf:Null<String>;
	var stage:String;
	var speed:Float;
	var ?bpmChanges:Array<BPMChange>;
	var keyCount:Int;
}

typedef SectionData = {
	var notes:Array<NoteData>;
	var focusAtOpponent:Bool;
	var newBPM:Null<Float>;
}

typedef EventData = {
	var strumTime:Float;
	var name:String;
	var args:Array<String>;
}

typedef NoteData = {
	var strumTime:Float;
	var length:Float;
	var dir:Int;
	var type:String;
}

/*** Processes or converts charts from various engines into Mint's own format. */
class ChartProcessor {
	public static function parsePsych(json:PsychChartData):ChartData {
		var chartObj:ChartData = makeEmptyChart();
		chartObj.keyCount = json.song.mania == null ? 4 : json.song.mania + 1;
		var bpmChanges:Array<BPMChange> = [];
		var lastBPM:Float = json.song.bpm;
		for (sectionIndex in 0...json.song.notes.length) {
			var notes:Array<NoteData> = [];
			var section:SectionData = makeEmptySection();
			final stinkySection:PsychSectionData = json.song.notes[sectionIndex];
			section.focusAtOpponent = stinkySection.mustHitSection;
			for (note in stinkySection.sectionNotes) {
				var iHateBaseGame:Int = note[1];
				if (section.focusAtOpponent) // NM WHY DID YOU HAVE TO DO THAT
					iHateBaseGame = iHateBaseGame < chartObj.keyCount ? iHateBaseGame + chartObj.keyCount : iHateBaseGame - chartObj.keyCount;
				notes.push({
					strumTime: note[0],
					length: note[2],
					dir: iHateBaseGame,
					type: note[3] == null ? '' : note[3]
				});
			}
			section.notes = notes;
			chartObj.sections[sectionIndex] = section;
			var sectionBPM:Float = json.song.notes[sectionIndex].bpm;
			if (sectionBPM != lastBPM) {
				lastBPM = sectionBPM;
				bpmChanges.push({section: sectionIndex, bpm: sectionBPM, crotchet: 60. / sectionBPM});
			}
		}
		for (event in json.song.events) {
			for (eventChunk in event) {
				chartObj.events.push({
					strumTime: event[0],
					name: eventChunk[0],
					args: [eventChunk[1], eventChunk[2]]
				});
			}
		}
		chartObj.noteskin = json.song.noteskin;
		chartObj.initialPlayer = json.song.player2;
		chartObj.initialOpponent = json.song.player1;
		chartObj.initialBPM = json.song.bpm;
		chartObj.gf = json.song.gfVersion;
		chartObj.speed = json.song.speed;
		chartObj.bpmChanges = bpmChanges;
		return chartObj;
	}

	public static inline function makeEmptyChart():ChartData {
		return {
			sections: [],
			events: [],
			initialBPM: 240,
			initialPlayer: 'bf',
			initialOpponent: 'dad',
			gf: 'gf',
			noteskin: 'default',
			stage: 'stage',
			speed: 3,
			keyCount: 4
		}
	}

	public static inline function makeEmptySection():SectionData {
		return {
			notes: [],
			focusAtOpponent: true,
			newBPM: null
		}
	}
}

typedef PsychChartData = {
	var song:{
		var notes:Array<PsychSectionData>;
		var noteskin:String;
		var stage:String;
		var speed:Float;
		var bpm:Float;
		var gfVersion:String;
		var events:Array<PsychEventData>;
		var disableNoteRGB:Bool;
		var song:String;
		var needsVoices:String;
		var player1:String;
		var player2:String;
		var ?mania:Int;
	};
}

typedef PsychSectionData = {
	var lengthInSteps:Int;
	var sectionNotes:Array<PsychNoteData>;
	var altAnim:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var mustHitSection:Bool;
}

/* [ strumTime:Float, dir:Int, sustainLength:Float, noteType:Null<String> ] */
typedef PsychNoteData = Array<Dynamic>;
/* [ strumTime:Float, [name:String, value1:String, value2:String] ] */
typedef PsychEventData = Array<Dynamic>;
