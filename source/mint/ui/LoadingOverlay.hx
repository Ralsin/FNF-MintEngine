package mint.ui;

import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.FlxSprite;

class LoadingOverlay {
	public var group:flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxBasic> = new flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxBasic>();
	public var camera:FlxCamera = new FlxCamera();
	#if hl
	var tweens:hl.NativeArray<FlxTween> = new hl.NativeArray(2);
	#else
	var tweens:Array<FlxTween> = [];
	#end
	var curState:Bool = false;
	public function new() {
		var bg = new FlxSprite().makeGraphic(1,1,0);
		bg.setGraphicSize(flixel.FlxG.width, flixel.FlxG.height);
		var text = new Alphabet(0,0,'loading...');
		text.center();
		text.y += 48.;
		group.add(bg);
		group.add(text);
	}
	public function toggle(state:Bool) {
		if (curState == state)
			return;
		curState = state;
		for (tween in tweens)
			tween.cancel();
		if (state) {
			var text:Alphabet = cast group.members[1];
			tweens[0] = FlxTween.tween(camera, {alpha: 1.}, 1.-camera.alpha);
			tweens[1] = FlxTween.tween(text, {alpha: 1.}, 1.-text.alpha);
		} else {
			var text:Alphabet = cast group.members[1];
			tweens[0] = FlxTween.tween(text, {alpha: 0.}, text.alpha, {onComplete: (_)->{
				tweens[0] = FlxTween.tween(camera, {alpha: 0.}, 1., {startDelay: .5});
			}});
		}
	}
}