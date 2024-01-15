package menus;

import backend.AudioManager;
import backend.MintFileManager;
import objects.Note.Note;
import objects.Note.NoteSprite;
import objects.Note.Splash;
import objects.Note.EventNote;
// import backend.Conductor;

typedef SectionData = {
    var lengthInSteps:Int;
	var sectionNotes:Array<Dynamic>;
	var altAnim:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var mustHitSection:Bool;
}
typedef SongData = {
    var song: {
        var notes:Array<SectionData>;
        var noteskin:String;
        var stage:String;
        var speed:Float;
        var BPM:Float;
        var events:Array<EventNote>;
    }
}

class PlayState extends extendable.Menu {
	public static var SongData:SongData;
    
	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curBeatDec:Float = 0;
    public var curSection:Int = 0;

    // var player1:Player;
    // var player2:Player;

	public function new(modName:String, songName:String, difficulty:String) {
		super();
		SongData = MintFileManager.getSongData('$songName-$difficulty');
		MintFileManager.currentModFolder = modName;
        AudioManager.loadSong('inst', 'vocals', difficulty, SongData.song.notes[0].bpm);
	}
    
    override function create() {
        
    }

    override function update(dt:Float) {

    }

    override function onBeatHit(curBeat:Int) {
        if (curBeat % 4 == 0) { // every section
            curSection++;
			for (rawNote in SongData.song.notes[curSection+2].sectionNotes) {

            }
        }
    }
    
    override function onKeyDown(repeated:Bool, keybind:String, key:String) {

    }
	override function onKeyUp(keybind:String, key:String) {

    }
}

