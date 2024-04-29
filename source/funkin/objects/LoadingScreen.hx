package funkin.objects;

import flixel.FlxSprite;
import flixel.text.FlxText;

class LoadingScreen extends flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxObject> {
	var bg:FlxSprite;
	var text:FlxText;
	var icon:FlxSprite;
	public function new() {
		super();
		bg = new FlxSprite();
	}
	override public function update(elapsed:Float) {
		super.update(elapsed);
		onUpdate(elapsed);
	}
	public dynamic function onUpdate(elapsed:Float) {

	}
	public dynamic function onProgress() {

	}
}