package funkin.objects;

import flixel.group.FlxGroup;
import flixel.FlxSprite;
import funkin.objects.Note;
import funkin.templates.NotePrefixes;
import funkin.menus.PlayState;

class StrumLine {
	private var index:Int;

	public var receptor(default, null):FlxSprite;
	public var notes(default, null):FlxTypedGroup<NoteSprite>;
	public var useOldPrefixes:Bool = true;

	public function new(index:Int) {
		this.index = index;
		receptor = new FlxSprite();
		setTexture();
		receptor.scale.set(.7, .7);
		receptor.animation.play('idle');
		receptor.updateHitbox();
		receptor.centerOffsets();
		receptor.centerOrigin();
		notes = new FlxTypedGroup<NoteSprite>();
	}

	public function update(elapsed:Float, forced:Bool = false) {
		receptor.update(elapsed);
		// receptor.updateHitbox();
		receptor.centerOrigin();
		for (note in notes)
			note.update(elapsed);
	}

	public function setTexture(spritePath:String = 'note-assets', ?framerate:Float = 24., ?affectNotes:Bool = false):Void {
		receptor.frames = funkin.api.FileManager.getFrames(spritePath);
		var prefixes = (useOldPrefixes ? NotePrefixes.old : NotePrefixes.old);
		receptor.animation.addByPrefix('idle', prefixes.arrow[PlayState.instance.keyCount-1][index], framerate, false);
		receptor.animation.addByPrefix('hit', prefixes.hit[PlayState.instance.keyCount-1][index], framerate, false);
		receptor.animation.addByPrefix('ghosted', prefixes.ghosted[PlayState.instance.keyCount-1][index], framerate, false);
	}
}