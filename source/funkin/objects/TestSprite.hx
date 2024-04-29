package funkin.objects;

import flixel.FlxCamera;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxRect;

class TestSprite extends flixel.FlxSprite {
	public var heldTime(default, set):Float = 0;
	public var length:Float = 2;
	public var calcLength:Float = 0.;
	public var speed:Float = 1;

	var bodyFramesCount:Int = 1;
	var endFramesCount:Int = 1;

	public function new() {
		super();
		screenCenter();
		x += 250;
		y -= 200;
		frames = funkin.api.FileManager.getFrames('note-assets');
		animation.addByPrefix('1', 'red hold piece', 0, false);
		animation.addByPrefix('2', 'red hold end', 0, false);
		alpha = .7;
		scale.set(.7, .7);
	}
	override function update(elapsed:Float) {
		if (funkin.api.Controls.isKeyHeld('J'))
			heldTime += elapsed;
		else if (funkin.api.Controls.isKeyHeld('K'))
			heldTime -= elapsed;
		else if (funkin.api.Controls.isKeyHeld('I'))
			speed += elapsed*4;
		else if (funkin.api.Controls.isKeyHeld('O'))
			speed -= elapsed*4;
		else if (funkin.api.Controls.isKeyHeld('P'))
			speed = 1;
		else if (funkin.api.Controls.isKeyHeld('G'))
			scale.y += elapsed/4;
		else if (funkin.api.Controls.isKeyHeld('H'))
			scale.y -= elapsed/4;
	}
	override function drawComplex(camera:flixel.FlxCamera) {
		final onePixelLmao:Float = 1 / graphic.bitmap.height;

		animation.play('1');

		final leframe:FlxRect = FlxRect.weak(frame.frame.x, frame.frame.y, frame.frame.width, frame.frame.height);
		leframe.width = leframe.width * scale.x;
		leframe.height = leframe.height * scale.y;
		leframe.x += leframe.width;
		leframe.y += leframe.height;

		final len:Float = (length - heldTime) * speed * (frame.frame.height / leframe.height);
		calcLength = len;
		final mulrest:Float = len - Math.floor(len);
		var placedLength:Float = 0;

		var vertices = [];
		var indices = [];
		var uvtdata = [];
		if (len > 1) {
			for (i in 0...Math.ceil(len)-1) {
				vertices = vertices.concat([
					0, placedLength,
					leframe.width, placedLength,
					leframe.width, placedLength+leframe.height,
					0, placedLength+leframe.height
				]);
				placedLength += leframe.height - .2 * scale.y;
				indices = indices.concat([4*i, 1+4*i, 2+4*i, 2+4*i, 3+4*i, 4*i]);
				uvtdata = uvtdata.concat([
					frame.uv.x, frame.uv.y,
					frame.uv.width, frame.uv.y,
					frame.uv.width, frame.uv.height - onePixelLmao,
					frame.uv.x, frame.uv.height - onePixelLmao
				]);
			}
			final stinkay = leframe.height - mulrest * leframe.height;
			vertices[1] += stinkay;
			vertices[3] += stinkay;
			uvtdata[1] += stinkay * onePixelLmao;
			uvtdata[3] += stinkay * onePixelLmao;
		}

		animation.play('2');

		final leframe2:FlxRect = FlxRect.weak(frame.frame.x, frame.frame.y, frame.frame.width, frame.frame.height);
		leframe2.width = leframe2.width * scale.x;
		leframe2.height = leframe2.height * scale.y;
		leframe2.x += leframe2.width - leframe2.width * .5;
		leframe2.y += leframe2.height - leframe2.height * .5;

		final i = Math.ceil(len)-1;
		vertices = vertices.concat([
			0, placedLength,
			leframe2.width, placedLength,
			leframe2.width, placedLength+leframe2.height,
			0, placedLength+leframe2.height
		]);
		indices = indices.concat([4*i, 1+4*i, 2+4*i, 2+4*i, 3+4*i, 4*i]);
		uvtdata = uvtdata.concat([
			frame.uv.x, frame.uv.y,
			frame.uv.width, frame.uv.y,
			frame.uv.width, frame.uv.height,
			frame.uv.x, frame.uv.height
		]);
		
		if (len <= 1) {
			final stinkay = leframe2.height - mulrest * leframe2.height;
			vertices[vertices.length-7] += stinkay;
			vertices[vertices.length-5] += stinkay;
			uvtdata[uvtdata.length-7] += stinkay * onePixelLmao;
			uvtdata[uvtdata.length-5] += stinkay * onePixelLmao;
		}

		final it = (len > 1 ? leframe : leframe2);

		camera.drawTriangles(
			graphic,
			new DrawData<Float>(vertices.length, true, vertices),
			new DrawData<Int>(indices.length, true, indices),
			new DrawData<Float>(uvtdata.length, true, uvtdata),
			getScreenPosition(camera).add(offset.x, offset.y).subtract(leframe.width, it.height).add(0, mulrest * it.height),
			blend,
			false,
			antialiasing,
			colorTransform,
			shader
		);
	}
	function set_heldTime(v:Float) {
		return heldTime = Math.max(0, Math.min(v, length));
	}
}