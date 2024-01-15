package backend;

import menus.PlayState.SongData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class MintFileManager {
	public static var currentModFolder(default, set):String = '';
	static var modCacheFolder:String = './cache/';

	// static var trackedPaths:Array<String> = [];

	public inline static function existsType(path:String, ignoreModFiles:Bool) {
		if (!ignoreModFiles && FileSystem.exists(modCacheFolder + path))
			return 'mod';
		if (FileSystem.exists('./assets/' + path))
			return 'asset';
		return null;
	}

	public inline static function getImage(path:String, ignoreModFiles:Bool = false, persist:Bool = false):FlxGraphic {
		path = 'images/' + path + '.png';
		var fpath:String = switch existsType(path, ignoreModFiles) {
			case 'mod':
				modCacheFolder + path;
			case 'asset':
				'./assets/' + path;
			default:
				null;
		}
		if (fpath != null) {
			var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(fpath), false, path);
			graphic.persist = persist;
			return graphic;
		}
		return null;
	}

	public inline static function getFrames(path:String, ignoreModFiles:Bool = false, persist:Bool = false) {
		var image:FlxGraphic = getImage(path, ignoreModFiles, persist);
		path = 'images/$path.xml';
		var atlas:String = existsType(path, ignoreModFiles) == 'mod' ? File.getContent(modCacheFolder + path) : File.getContent('./assets/' + path);
		return FlxAtlasFrames.fromSparrow(image, atlas);
	}

	// public inline static function getSparrowAtlas(path:String, ignoreModFiles:Bool = false):FlxAtlasFrames {
	// 	var imageLoaded:FlxGraphic = getImage(path, ignoreModFiles);
	// 	var xmlExists = FileSystem.exists(modsXml(path));
	// 	return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)),
	// 		(xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
	// }

	public inline static function getSound(path:String, ignoreModFiles:Bool = false):Sound {
		path = 'sounds/' + path + '.ogg';
		var fpath:String = switch existsType(path, ignoreModFiles) {
			case 'mod':
				modCacheFolder + path;
			case 'asset':
				'./assets/' + path;
			default:
				null;
		}
		if (fpath != null)
			return Sound.fromFile(fpath);
		return null;
	}

	public inline static function getMusic(path:String):Sound {
		path = './assets/music/' + path + '.ogg';
		if (FileSystem.exists(path))
			return Sound.fromFile(path);
		return null;
	}

	public inline static function getSong(instName:String, vocalsName:String, difficulty:String = ''):{var inst:Sound; var vocals:Sound; var hasVocals:Bool;} {
		instName = modCacheFolder + instName + '.ogg';
		vocalsName = modCacheFolder + vocalsName + '.ogg';
		var inst:Sound = null;
		var vocals:Sound = null;
		if (FileSystem.exists(instName))
			inst = Sound.fromFile(instName);
		if (FileSystem.exists(vocalsName))
			vocals = Sound.fromFile(vocalsName);
		return {inst: inst, vocals: vocals, hasVocals: vocals != null};
	}

	/**
	 * Path starts from the assets/mod folder, so you can get audio in any folder either it be `sounds/audioFile` or `songs/audio/audioFile`.
	 */
	public inline static function getAudios(paths:Array<String>, ignoreModFiles:Bool = false):Map<String, Sound> {
		var audios:Map<String, Sound> = [];
		if (ignoreModFiles) {
			for (path in paths) {
				var modPath:String = modCacheFolder + path + '.ogg';
				var assetPath:String = './assets/' + path + '.ogg';
				if (FileSystem.exists(modPath))
					audios.set(path, Sound.fromFile(modPath));
				else if (FileSystem.exists(assetPath))
					audios.set(path, Sound.fromFile(assetPath));
			}
		} else {
			for (path in paths) {
				var assetPath:String = './assets/' + path + '.ogg';
				if (FileSystem.exists(assetPath))
					audios.set(path, Sound.fromFile(assetPath));
			}
		}
		return audios;
	}

	public inline static function getSongData(path:String):SongData {
		return readJson(File.getContent(path+'.json'));
	}

	public static function readJson(json:String):Dynamic {
		json = json.trim();
		while (!json.endsWith("}"))
			json = json.substr(0, json.length - 1);
		return haxe.Json.parse(json);
	}

	static function set_currentModFolder(folder:String) {
		modCacheFolder = './cache/' + folder + '/';
		return currentModFolder = folder;
	}
}
