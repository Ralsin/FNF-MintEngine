package objects;

import api.MintFileManager;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

class StrumLine {
	private var index:Int;
	private var totalKeys:Int = 4;

	public var receptor(default, null):FlxSprite;
	public var notes(default, null):Array<FlxSprite>;
	public var sustains(default, null):Array<FlxSprite>;

	public function new(index:Int, totalKeys:Int = 4) {
		receptor = new FlxSprite();
		notes = [];
		sustains = [];
	}

	public function update(elapsed:Float, forced:Bool = false) {
		receptor.update(elapsed);
		for (note in notes)
			note.update(elapsed);
		for (sustain in sustains)
			sustain.update(elapsed);
	}

	public function setTexture(oldPrefixes:Bool = false, spritePath:String, framerate:Float = 24.):Void {
		receptor.frames = MintFileManager.getFrames(spritePath);
		receptor.animation.addByPrefix('idle', 'arrow' + maniaDirections[index], 24., false);
	}
}

final maniaDirections:Array<Array<String>> = [
	['UP'],
	['LEFT', 'RIGHT'],
	['LEFT', 'UP', 'RIGHT'],
	['LEFT', 'DOWN', 'UP', 'RIGHT']
];