package backend;

import flixel.input.FlxInput;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

typedef Keybinds = Map<String, Array<String>>;
typedef Key = FlxInput<Int>;

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

		ThanksFlixelInput.init();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (event:KeyboardEvent) -> {
			var key = ThanksFlixelInput.resolve(event);
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
			var key = ThanksFlixelInput.resolve(event);
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
}

// bullshit flixel does so i got it for compability
private class ThanksFlixelInput {
	// static var _keyListMap:Map<Int, Int> = [];
	static var _nativeCorrection:Map<String, String> = [];

	public static function init() {
		// for (code in FlxKey.fromStringMap) {
		// 	if (code != FlxKey.ANY && code != FlxKey.NONE) {
		// 		// var input = new flixel.input.FlxInput(code);
		// 		// _keyListArray.push(input);
		// 		_keyListMap.set(code, new FlxInput(code));
		// 	}
		// }

		_nativeCorrection.set("0_64", "INSERT");
		_nativeCorrection.set("0_65", "END");
		_nativeCorrection.set("0_67", "PAGEDOWN");
		_nativeCorrection.set("0_69", "NONE");
		_nativeCorrection.set("0_73", "PAGEUP");
		_nativeCorrection.set("0_266", "DELETE");
		_nativeCorrection.set("123_222", "LBRACKET");
		_nativeCorrection.set("125_187", "RBRACKET");
		_nativeCorrection.set("126_233", "GRAVEACCENT");

		_nativeCorrection.set("0_80", "F1");
		_nativeCorrection.set("0_81", "F2");
		_nativeCorrection.set("0_82", "F3");
		_nativeCorrection.set("0_83", "F4");
		_nativeCorrection.set("0_84", "F5");
		_nativeCorrection.set("0_85", "F6");
		_nativeCorrection.set("0_86", "F7");
		_nativeCorrection.set("0_87", "F8");
		_nativeCorrection.set("0_88", "F9");
		_nativeCorrection.set("0_89", "F10");
		_nativeCorrection.set("0_90", "F11");

		_nativeCorrection.set("48_224", "ZERO");
		_nativeCorrection.set("49_38", "ONE");
		_nativeCorrection.set("50_233", "TWO");
		_nativeCorrection.set("51_34", "THREE");
		_nativeCorrection.set("52_222", "FOUR");
		_nativeCorrection.set("53_40", "FIVE");
		_nativeCorrection.set("54_189", "SIX");
		_nativeCorrection.set("55_232", "SEVEN");
		_nativeCorrection.set("56_95", "EIGHT");
		_nativeCorrection.set("57_231", "NINE");

		_nativeCorrection.set("48_64", "NUMPADZERO");
		_nativeCorrection.set("49_65", "NUMPADONE");
		_nativeCorrection.set("50_66", "NUMPADTWO");
		_nativeCorrection.set("51_67", "NUMPADTHREE");
		_nativeCorrection.set("52_68", "NUMPADFOUR");
		_nativeCorrection.set("53_69", "NUMPADFIVE");
		_nativeCorrection.set("54_70", "NUMPADSIX");
		_nativeCorrection.set("55_71", "NUMPADSEVEN");
		_nativeCorrection.set("56_72", "NUMPADEIGHT");
		_nativeCorrection.set("57_73", "NUMPADNINE");

		_nativeCorrection.set("43_75", "NUMPADPLUS");
		_nativeCorrection.set("45_77", "NUMPADMINUS");
		_nativeCorrection.set("47_79", "SLASH");
		_nativeCorrection.set("46_78", "NUMPADPERIOD");
		_nativeCorrection.set("42_74", "NUMPADMULTIPLY");
	}

	public static function resolve(e:KeyboardEvent):String {
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		return code == null ? FlxKey.toStringMap.get(e.keyCode) : code;
	}
}
