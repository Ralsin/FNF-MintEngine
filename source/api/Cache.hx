package api;

import openfl.media.Sound;
import openfl.display.Bitmap;
import mint.ModMetadata;
import api.ChartParser.ChartData;

typedef Path = String;

class Cache {
	public static var bitmap(default, null):Map<Path, Bitmap> = new Map();
	public static var audio(default, null):Map<Path, Sound> = new Map();
	@:allow(menus.PlayState) public static var currentChart(default, null):ChartData = null;
	@:allow(menus.PlayState) public static var modData(default, null):ModMetadata = null;
}