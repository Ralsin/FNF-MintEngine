package mint.ui;

import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import api.MintFileManager;

class Alphabet extends FlxTypedSpriteGroup<AlphabetCharacter> {
	public var text(default, set):String;
	public var spacing(default, set):Float = 0.;
	public var isBold(default, null):Bool;
	// public var fieldWidth(default, set):Int = 0;
	// public var align(default, set):String = "left";
	public var textScale(default, set):Float = 1.;

	/**
	 * Creates a new alphabet object.
	 */
	public function new(x:Float, y:Float, text:String, ?bold:Bool = true) {
		Characters.frames ??= MintFileManager.getFrames('alphabet', true, true);
		super(x, y);
		this.x = x;
		this.y = y;
		this.isBold = bold;
		this.text = text;
	}

	function set_text(str:String) {
		var iwtkms:Int = members.length;
		while (iwtkms-- > 0)
			remove(members[iwtkms], true).destroy();
		var thex:Float = .0;
		for (i in 0...str.length) {
			var char = str.charAt(i);
			var sprite = new AlphabetCharacter(char, isBold, thex, 0., i, this);
			@:privateAccess thex = sprite.ogX + sprite.frameWidth + spacing;
			sprite.updateHitbox();
			add(sprite);
		}
		return this.text = str;
	}

	function set_spacing(value:Float) {
		for (i in 1...members.length) {
			var prevChar:AlphabetCharacter = members[i - 1];
			var curChar:AlphabetCharacter = members[i];
			@:privateAccess curChar.x = curChar.ogX = prevChar.x + prevChar.frameWidth + curChar.offsetX + value;
			curChar.updateHitbox();
		}
		return spacing = value;
	}

	function set_textScale(value:Float) {
		for (i in 1...members.length) {
			var prevChar:AlphabetCharacter = members[i - 1];
			var curChar:AlphabetCharacter = members[i];
			@:privateAccess curChar.ogX = prevChar.ogX + prevChar.frameWidth * value;
			curChar.updateHitbox();
		}
		return spacing = value;
	}

	// function set_fieldWidth(value:Int) {
	// 	return fieldWidth = value;
	// }

	// function set_align(value:String) {
	// 	return align = value;
	// }

	public function forChar(Function:AlphabetCharacter->Void) {
		for (char in members)
			Function(cast char);
	}

	public function center(axes:FlxAxes = XY) { // screenCenter but rounded to prevent weird distortion
		if (axes.x)
			x = Math.floor((FlxG.width - width) / 2.);
		if (axes.y)
			y = Math.floor((FlxG.height - height) / 2.);

		return this;
	}
}

class AlphabetCharacter extends FlxSprite {
	public var ogX(null, null):Float;
	public var ogY(null, null):Float;

	var characterOffsetX:Float = 0.;
	var characterOffsetY:Float = 0.;
	var groupRef:Alphabet; // so it has a way to get the group position, otherwise changing position sets it to world position

	public var offsetX(default, set):Float = 0.;
	public var offsetY(default, set):Float = 0.;
	public var char:String;
	public var charString:String;

	public function new(char:String, bold:Bool = false, x:Float = 0., y:Float = 0., index:Int = 0, ?groupRef:Alphabet) {
		this.groupRef = groupRef;
		this.char = char;
		if (bold) {
			charString = char.toLowerCase();
			switch (char) {
				case '"':
					char = "quote bold";
				case ' ':
					char = "space";
				default:
					var charL = char.toLowerCase();
					char = Characters.cantBeBold.get(charL) == null ? charL + " bold" : "? bold";
					// (Characters.list.exists(char) ? Characters.list.get(char) : char + " normal");
			}
			var stinkyOffsets = Characters.offsets.get(charString);
			characterOffsetX = stinkyOffsets[2];
			characterOffsetY = stinkyOffsets[3];
			ogX = x;
			ogY = y;
		} else {
			charString = char;
			switch (char) {
				case '"':
					char = "quote normal";
				case ' ':
					char = "space";
				default:
					char = Characters.list.exists(char) ? Characters.list.get(char) : char + " normal";
			}
			var stinkyOffsets = Characters.offsets.get(charString);
			characterOffsetX = stinkyOffsets[0];
			characterOffsetY = stinkyOffsets[1];
			ogX = x;
			ogY = y;
		}
		super(x + characterOffsetX, y + characterOffsetY);
		frames = Characters.frames;
		animation.addByPrefix('a', char, 24);
		animation.play('a');
		updateHitbox();
	}

	function set_offsetX(value:Float) {
		this.x = groupRef != null ? groupRef.x + ogX + characterOffsetX + value : ogX + characterOffsetX + value;
		return offsetX = value;
	}

	function set_offsetY(value:Float) {
		this.y = groupRef != null ? groupRef.y + ogY + characterOffsetY + value : ogY + characterOffsetY + value;
		return offsetY = value;
	}
}

class Characters {
	// dumb
	public static var frames:flixel.graphics.frames.FlxAtlasFrames;
	public static final list:Map<String, String> = [
		"a" => "a lowercase", "A" => "a uppercase", "b" => "b lowercase", "B" => "b uppercase", "c" => "c lowercase", "C" => "c uppercase",
		"d" => "d lowercase", "D" => "d uppercase", "e" => "e lowercase", "E" => "e uppercase", "f" => "f lowercase", "F" => "f uppercase",
		"g" => "g lowercase", "G" => "g uppercase", "h" => "h lowercase", "H" => "h uppercase", "i" => "i lowercase", "I" => "i uppercase",
		"j" => "j lowercase", "J" => "j uppercase", "k" => "k lowercase", "K" => "k uppercase", "l" => "l lowercase", "L" => "l uppercase",
		"m" => "m lowercase", "M" => "m uppercase", "n" => "n lowercase", "N" => "n uppercase", "o" => "o lowercase", "O" => "o uppercase",
		"p" => "p lowercase", "P" => "p uppercase", "q" => "q lowercase", "Q" => "q uppercase", "r" => "r lowercase", "R" => "r uppercase",
		"s" => "s lowercase", "S" => "s uppercase", "t" => "t lowercase", "T" => "t uppercase", "u" => "u lowercase", "U" => "u uppercase",
		"v" => "v lowercase", "V" => "v uppercase", "w" => "w lowercase", "W" => "w uppercase", "x" => "x lowercase", "X" => "x uppercase",
		"y" => "y lowercase", "Y" => "y uppercase", "z" => "z lowercase", "Z" => "z uppercase"
	];
	public static final cantBeBold:Map<String, Bool> = [
		"@" => true, "#" => true, "$" => true, "%" => true, "^" => true, "_" => true, "[" => true, "]" => true, ":" => true, ";" => true, "|" => true,
		"~" => true, "\\" => true, "/" => true
	];
	public static final offsets:Map<String, Array<Float>> = [
		"a" => [0, 0, 0, 0], "A" => [0, 0, 0, 0], "b" => [0, 0, 0, 0], "B" => [0, 0, 0, 0], "c" => [0, 0, 0, 0], "C" => [0, 0, 0, 0], "d" => [0, 0, 0, 0],
		"D" => [0, 0, 0, 0], "e" => [0, 0, 0, 0], "E" => [0, 0, 0, 0], "f" => [0, 0, 0, 0], "F" => [0, 0, 0, 0], "g" => [0, 0, 0, 0], "G" => [0, 0, 0, 0],
		"h" => [0, 0, 0, 0], "H" => [0, 0, 0, 0], "i" => [0, 0, 0, 0], "I" => [0, 0, 0, 0], "j" => [0, 0, 0, 0], "J" => [0, 0, 0, 0], "k" => [0, 0, 0, 0],
		"K" => [0, 0, 0, 0], "l" => [0, 0, 0, 0], "L" => [0, 0, 0, 0], "m" => [0, 0, 0, 0], "M" => [0, 0, 0, 0], "n" => [0, 0, 0, 0], "N" => [0, 0, 0, 0],
		"o" => [0, 0, 0, 0], "O" => [0, 0, 0, 0], "p" => [0, 0, 0, 0], "P" => [0, 0, 0, 0], "q" => [0, 0, 0, 0], "Q" => [0, 0, 0, 0], "r" => [0, 0, 0, 0],
		"R" => [0, 0, 0, 0], "s" => [0, 0, 0, 0], "S" => [0, 0, 0, 0], "t" => [0, 0, 0, 0], "T" => [0, 0, 0, 0], "u" => [0, 0, 0, 0], "U" => [0, 0, 0, 0],
		"v" => [0, 0, 0, 0], "V" => [0, 0, 0, 0], "w" => [0, 0, 0, 0], "W" => [0, 0, 0, 0], "x" => [0, 0, 0, 0], "X" => [0, 0, 0, 0], "y" => [0, 0, 0, 0],
		"Y" => [0, 0, 0, 0], "z" => [0, 0, 0, 0], "Z" => [0, 0, 0, 0], "1" => [0, 0, 0, 0], "2" => [0, 0, 0, 0], "3" => [0, 0, 0, 0], "4" => [0, 0, 0, 0],
		"5" => [0, 0, 0, 0], "6" => [0, 0, 0, 0], "7" => [0, 0, 0, 0], "8" => [0, 0, 0, 0], "9" => [0, 0, 0, 0], "0" => [0, 0, 0, 0], "@" => [0, 0, 0, 0],
		"#" => [0, 0, 0, 0], "$" => [0, 0, 0, 0], "%" => [0, 0, 0, 0], "^" => [0, -28, 0, 0], "&" => [0, 0, 0, 2], "*" => [0, 28, 0, 0], "(" => [0, 0, 0, -5],
		")" => [0, 0, 0, -5], "-" => [0, -16, 0, 30], "_" => [0, 0, 0, 0], "+" => [0, -7, 0, 12], "[" => [0, 0, 0, 0], "]" => [0, 1, 0, 0],
		"<" => [0, 0, 0, -4], ">" => [0, 0, 0, -4], ":" => [0, -2, 0, 0], ";" => [0, 2, 0, 0], "|" => [0, 0, 0, 0], "~" => [0, -16, 0, 0],
		"\\" => [0, 0, 0, 0], "/" => [0, 0, 0, 0], "," => [0, 6, 0, 0], "." => [0, 0, 0, 48], "'" => [0, -32, 0, 0], '"' => [0, -32, 0, 0],
		"!" => [0, 0, 0, -10], "?" => [0, 0, 0, -4], ' ' => [0, 0, 0, 0]];
}
