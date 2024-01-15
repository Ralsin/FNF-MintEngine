package objects;

import flixel.FlxSprite;
class Note {
    var data: {}
}
class NoteSprite extends FlxSprite {
    var reference:Note;

}
class Splash extends FlxSprite {

}
class EventNote {
    public var hitTime:Float;
	public var name:String;
	public var values:Array<String>;
    public function new(hitTime:Float, name:String, values:Array<String>) {
		this.hitTime = hitTime;
		this.name = name;
		this.values = values;
    }
}