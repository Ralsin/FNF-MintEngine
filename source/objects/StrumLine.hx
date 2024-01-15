package objects;

import backend.MintFileManager;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

class StrumLine {
	private var index:Int;
	private var totalKeys:Int = 4;

	public var receptor(default, null):FlxSprite;
	public var notes(default, null):FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	public var sustains(default, null):FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	public function new(index:Int, totalKeys:Int = 4) {
		receptor = new FlxSprite();
	}

	public function setTexture(oldPrefixes:Bool = false, spritePath:String, framerate:Float = 24.) {
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