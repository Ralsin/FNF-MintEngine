package funkin.objects;

import funkin.menus.PlayState;
import flixel.FlxSprite;
import funkin.math.Point;
import flixel.math.FlxRect;
import funkin.templates.NotePrefixes;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;

class NoteSprite extends FlxSprite {
	public var useOldPrefixes:Bool = true;
	@:allow(funkin.menus.PlayState) public var reference(default, null):funkin.api.ChartProcessor.NoteData;
	public var sustain(default, null):SustainSprite;
	var textureSet:Bool = false;

	public var wasHit:Bool = false;

	public function new(data:Int, time:Float, length:Float = 0, type:String = '') {
		super();
		reference = {
			strumTime: time,
			length: length,
			dir: data,
			type: type
		}
		// recycling shit
		if (sustain != null) {
			sustain.destroy();
			sustain = null;
		}
		// if (length > .1)
			// sustain = new SustainSprite(this);
		scale.set(.7, .7);
		// <- call hscript onNoteSpawn here
		if (!textureSet)
			setTexture(data);

		if (sustain != null)
			sustain.scale.set(scale.x, scale.y);
		
		updateHitbox();
		centerOffsets();
		centerOrigin();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (sustain == null)
			return;
		sustain.x = x + width * .5;
		sustain.y = y;
		sustain.update(elapsed);
	}
	override function draw() {
		if (sustain != null)
			sustain.draw();
		super.draw();
	}
	public function setTexture(data:Int, spritePath:String = 'note-assets', ?framerate:Float = 24.) {
		frames = funkin.api.FileManager.getFrames(spritePath);
		var prefixes = (useOldPrefixes ? NotePrefixes.old : NotePrefixes.old); // gonna change prefixes sometime in the future
		animation.addByPrefix('idle', prefixes.note[PlayState.instance.keyCount-1][reference.dir], framerate, false);
		animation.play('idle');
		textureSet = true;
	}
}

class SustainSprite extends FlxSprite {
	public var note(default, null):NoteSprite;
	public var heldTime:Float = 0.;

	public function new(parent:NoteSprite) {
		super();
		note = parent;
		final prefixes = (parent.useOldPrefixes ? NotePrefixes.old : NotePrefixes.old);
		final notedir = note.reference.dir < PlayState.instance.keyCount ? note.reference.dir : note.reference.dir - PlayState.instance.keyCount;
		animation.addByPrefix('1', prefixes.holdPattern[PlayState.instance.keyCount-1][notedir], 0, false);
		animation.addByPrefix('2', prefixes.holdEnd[PlayState.instance.keyCount-1][notedir], 0, false);
		note = parent;
	}
	
	override function drawComplex(camera:flixel.FlxCamera) {
		final onePixelLmao:Float = 1 / graphic.bitmap.height;

		animation.play('1');

		final leframe:FlxRect = FlxRect.weak(frame.frame.x, frame.frame.y, frame.frame.width, frame.frame.height);
		leframe.width = leframe.width * scale.x;
		leframe.height = leframe.height * scale.y;
		leframe.x += leframe.width - leframe.width * .5;
		leframe.y += leframe.height - leframe.height * .5;

		final len:Float = (note.reference.length - heldTime) * PlayState.instance.chartData.speed * (frame.frame.height / leframe.height);
		final lenrest:Float = len - Math.floor(len);
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
			final stinkay = leframe.height - lenrest * leframe.height;
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
			final stinkay = leframe2.height - lenrest * leframe2.height;
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
			getScreenPosition(camera).add(offset.x, offset.y).subtract(leframe.width, it.height).add(0, lenrest * it.height),
			blend,
			false,
			antialiasing,
			colorTransform,
			shader
		);
	}

	function set_heldTime(v:Float) {
		return heldTime = Math.max(0, Math.min(v, note.reference.length));
	}
}
class Splash extends FlxSprite {}

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
