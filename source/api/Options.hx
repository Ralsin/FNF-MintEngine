package api;

import flixel.util.typeLimit.OneOfFour;
import api.AudioManager;

class Options {
	public static final Game_Version:String = '0.0.0 (unfinished preview)';

	public static var Volume(default, set):Int = 50;
	public static var AudioOffset(default, set):Int = 0;

	public static var FlashingLights:Bool = true;
	public static var AllowGPU:Bool = false;

	// static var gameProperties:GameProperties;

	static function set_Volume(value:Int) {
		return Volume = mint.ui.VolumeTray.volume = value;
	}

	static function set_AudioOffset(value:Int):Int
		return AudioOffset = AudioManager.offset = value;
}

// typedef GameProperties = {
//     var inMenu:Bool;
// }
// typedef Option = {
//     var type:String = 'bool'|'float'|'integer';
//     var defaultValue:Bool | Float | Integer;
// }

// class Option<@:const T> {
// 	public var type:String;
// 	public var value:T;
// 	public var defaultValue:T;
// 	public var step:Float;

// 	public function new(type:String, defaultValue:OptionValue, step:Float) {
// 		if ($type(T))
// 			return;
// 	}
// }
class BoolOption {
	public final type:String = 'Bool';
	public var value:Bool;
	public var defaultValue:Bool;

	public function new(defaultValue:Bool) {
		this.value = this.defaultValue = defaultValue;
	}
}

class IntOption {
	public final type:String = 'Int';
	public var value:Int;
	public var defaultValue:Int;
	public final step:Int = 1;

	public function new(defaultValue:Int) {
		this.value = this.defaultValue = defaultValue;
	}
}

class FloatOption {
	public final type:String = 'Float';
	public var value:Float;
	public var defaultValue:Float;
	public var step:Float = 1.;

	public function new(defaultValue:Float, step:Float = 1.) {
		this.value = this.defaultValue = defaultValue;
	}

	public function nextValue() {
		value += step;
		return value;
	}

	public function previousValue() {
		value -= step;
		return value;
	}
}
typedef Option = OneOfFour<Bool, Float, Int, Array<String>>;