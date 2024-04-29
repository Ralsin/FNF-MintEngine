package funkin.api;

import openfl.display.BitmapData;
import openfl.media.Sound;

typedef Path = String;

class Cache {
	public static var bitmapdata(default, null):Map<Path, BitmapData>;
	public static var audio(default, null):Map<Path, Sound>;
	static function __init__() {
		bitmapdata = new Map<Path, BitmapData>();
		audio = new Map<Path, Sound>();
	}
}