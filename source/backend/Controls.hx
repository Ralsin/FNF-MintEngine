package backend;

import flixel.input.FlxInput;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

typedef Keybinds = Map<String, Array<String>>;

final defaultKeybinds:Keybinds = [
	"UI_Left" => ["LEFT", "A"],
	"UI_Down" => ["DOWN", "S"],
	"UI_Up" => ["UP", "W"],
	"UI_Right" => ["RIGHT", "D"],
	"Left" => ["LEFT", "A"],
	"Down" => ["DOWN", "S"],
	"Up" => ["UP", "W"],
	"Right" => ["RIGHT", "D"],
	"Accept" => ["ENTER", "Z"],
	"Back" => ["ESCAPE", "BACKSPACE"],
	"Special1" => ["SPACE", "NONE"],
	"Special2" => ["ALT", "NONE"],
	"Volume_Up" => ["PLUS", "NUMPADPLUS"],
	"Volume_Down" => ["MINUS", "NUMPADMINUS"],
	"Volume_Mute" => ["ZERO", "NUMPADZERO"]
];

class Controls {
	static var keybinds:Keybinds;
	static var holdTime:Map<String, Float> = [];

	public static function init() {
		if (keybinds != null)
			return;

		if (FlxG.save.data.keybinds == null) {
			keybinds = FlxG.save.data.keybinds = defaultKeybinds;
			FlxG.save.flush();
		} else
			keybinds = FlxG.save.data.keybinds;

		// checking for missing keybinds
		var anyKeybindMissing:Bool = false;
		for (keybind in defaultKeybinds.keys())
			if (keybinds.get(keybind) == null) {
				anyKeybindMissing = true;
				keybinds.set(keybind, defaultKeybinds.get(keybind));
			}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (event:KeyboardEvent) -> {
			var key = resolve(event);
			if (holdTime.get(key) == null) {
				for (bind => keys in keybinds) {
					if (keys[0] == key || keys[1] == key)
						MainState.instance.onKeyDown(false, bind, key);
				}
				holdTime.set(key, 0.);
			} else {
				for (key in holdTime.keys()) {
					for (bind => keys in keybinds) {
						if (keys[0] == key || keys[1] == key)
							MainState.instance.onKeyDown(true, bind, key);
					}
				}
			}
		});
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, (event:KeyboardEvent) -> {
			var key = resolve(event);
			holdTime.remove(key);
			for (bind => keys in keybinds) {
				if (keys[0] == key || keys[1] == key) {
					MainState.instance.onKeyUp(bind, key);
					MainState.instance.curSubState.onKeyUp(bind, key);
				}
			}
		});
	}

	public static function update(t:Float)
		for (k in holdTime.keys())
			holdTime[k] += t;

	public static function rebind(name:String, key:FlxKey, isALT:Bool) {
		var keys:Array<String> = keybinds.get(name);
		if (isALT)
			keys[1] = key.toString();
		else
			keys[0] = key.toString();

		keybinds.set(name, keys);
	}

	public static function saveKeybinds() {
		FlxG.save.data.keybinds = keybinds;
		FlxG.save.flush();
	}

	public static function isKeyHeld(key:String) {
		return holdTime.get(key) == null ? false : true;
	}

	public static function isKeybindHeld(keybind:String) {
		var keys = keybinds.get(keybind);
		return isKeyHeld(keys[0]) || isKeyHeld(keys[1]);
	}

	static var _nativeCorrection:Map<String, String> = [
		'0_64' => 'INSERT',
		'0_65' => 'END',
		'0_67' => 'PAGEDOWN',
		'0_69' => 'NONE',
		'0_73' => 'PAGEUP',
		'0_266' => 'DELETE',
		'123_222' => 'LBRACKET',
		'125_187' => 'RBRACKET',
		'126_233' => 'GRAVEACCENT',
		'0_80' => 'F1',
		'0_81' => 'F2',
		'0_82' => 'F3',
		'0_83' => 'F4',
		'0_84' => 'F5',
		'0_85' => 'F6',
		'0_86' => 'F7',
		'0_87' => 'F8',
		'0_88' => 'F9',
		'0_89' => 'F10',
		'0_90' => 'F11',
		'48_224' => 'ZERO',
		'49_38' => 'ONE',
		'50_233' => 'TWO',
		'51_34' => 'THREE',
		'52_222' => 'FOUR',
		'53_40' => 'FIVE',
		'54_189' => 'SIX',
		'55_232' => 'SEVEN',
		'56_95' => 'EIGHT',
		'57_231' => 'NINE',
		'48_64' => 'NUMPADZERO',
		'49_65' => 'NUMPADONE',
		'50_66' => 'NUMPADTWO',
		'51_67' => 'NUMPADTHREE',
		'52_68' => 'NUMPADFOUR',
		'53_69' => 'NUMPADFIVE',
		'54_70' => 'NUMPADSIX',
		'55_71' => 'NUMPADSEVEN',
		'56_72' => 'NUMPADEIGHT',
		'57_73' => 'NUMPADNINE',
		'43_75' => 'NUMPADPLUS',
		'45_77' => 'NUMPADMINUS',
		'47_79' => 'SLASH',
		'46_78' => 'NUMPADPERIOD',
		'42_74' => 'NUMPADMULTIPLY'
	];

	static function resolve(e:KeyboardEvent):String {
		var code = _nativeCorrection.get(e.charCode + '_' + e.keyCode);
		return code == null ? FlxKey.toStringMap.get(e.keyCode) : code;
	}
}