package funkin.api;

import haxe.Exception;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.Assets;
import sys.FileSystem;

using StringTools;

class FileManager {
	public static var modFolder:String = null;
	public static function workingDirectory(path:String, extension:String, ignoreModFiles:Bool) {
		if (extension.charAt(0) != '.')
			extension = '.$extension';

		if (!ignoreModFiles && modFolder != null) {
			if (FileSystem.exists('mods/global/$modFolder/$path$extension'))
				return 'mods/global/$modFolder/$path$extension';
	
			if (FileSystem.exists('mods/$modFolder/$path$extension'))
				return 'mods/$modFolder/$path$extension';
		}
		
		if (#if EMBED_ASSETS Assets.exists('assets/$path$extension')#else FileSystem.exists('assets/$path$extension')#end)
			return 'assets/$path$extension';

		return null;
	}

	public static function getImage(path:String, ignoreModFiles:Bool = false, persist:Bool = false, avoidGPU:Bool = false) {
		final dir_image:String = workingDirectory('images/$path', '.png', ignoreModFiles);
		trace(dir_image + ' // ' + path);
		if (dir_image == null)
			return null;
		var bitmap:BitmapData = Cache.bitmapdata.get(path);
		if (bitmap == null) {
			bitmap = #if EMBED_ASSETS (dir_image.startsWith('assets/') ? Assets.getBitmapData(dir_image, false) : BitmapData.fromFile(dir_image)) #else BitmapData.fromFile(dir_image) #end;
			Cache.bitmapdata.set(path, bitmap);
		}
		trace(bitmap);
		if (/*funkin.api.Options.AllowGPU &&*/ !avoidGPU && bitmap.image != null) {
			trace('[MFM] Loading $dir_image into GPU.');
			@:privateAccess {
				bitmap.lock();
				if (bitmap.__texture == null) {
					bitmap.image.premultiplied = true;
					bitmap.getTexture(flixel.FlxG.stage.context3D);
				}
				bitmap.getSurface();
				bitmap.disposeImage();
				bitmap.image.data = null;
				bitmap.image = null;
				bitmap.readable = true; // hashlink fix
			}
			trace('[MFM] Finished loading $dir_image into GPU.');
		}
		var graphic = FlxGraphic.fromBitmapData(bitmap, false, path, false);
		graphic.persist = persist;
		return graphic;
	}

	public static function getFrames(path:String, ignoreModFiles:Bool = false, persist:Bool = false, avoidGPU:Bool = false) {
		final image:FlxGraphic = getImage(path, ignoreModFiles, persist, avoidGPU);
		if (image == null)
			return null;
		final dir_xml:String = workingDirectory('images/$path', '.xml', ignoreModFiles);
		if (dir_xml == null)
			return null;
		final xml:String = #if EMBED_ASSETS (dir_xml.startsWith('assets/') ? Assets.getText : File.getContent) #else File.getContent #end (dir_xml);
		return FlxAtlasFrames.fromSparrow(image, xml);
	}

	public static function getSound(path:String, ignoreModFiles:Bool = false) {
		if (Cache.audio.get(path) == null) {
			final dir_sound:String = workingDirectory('sounds/$path', '.ogg', ignoreModFiles);
			if (dir_sound == null)
				return null;
			final sound:Sound = #if EMBED_ASSETS (dir_sound.startsWith('assets/') ? Assets.getSound(dir_sound, false) : Sound.fromFile(dir_sound)) #else Sound.fromFile(dir_sound) #end;
			Cache.audio.set(path, sound);
			return sound;
		}
		return Cache.audio.get(path);
	}

	public static function getMusic(path:String, ignoreModFiles:Bool = false) {
		if (Cache.audio.get('music://$path') == null) {
			final dir_sound:String = workingDirectory('music/$path', '.ogg', ignoreModFiles);
			if (dir_sound == null)
				return null;
			final sound:Sound = #if EMBED_ASSETS (dir_sound.startsWith('assets/') ? Assets.getSound(dir_sound, false) : Sound.fromFile(dir_sound)) #else Sound.fromFile(dir_sound) #end;
			Cache.audio.set('music://$path', sound);
			return sound;
		}
		return Cache.audio.get('music://$path');
	}

	public static function getSong(path:String, ignoreModFiles:Bool = false) {
		var inst:Sound = null; // "Local variable inst used without being initialized" my ass
		var vocals:Sound = null;
		var vocalsOpponent:Sound = null;
		var instExisted:Bool = false;
		var vocalsExisted:Bool = false;
		var oppVocalsExisted:Bool = false;
		if (Cache.audio.get('song://$path/inst') == null) {
			var dir_inst:String = aliasBullshit('songs/$path/{alias}', ['inst', 'instrumental'], '.ogg', ignoreModFiles);
			if (dir_inst == null)
				return null;
			inst = #if EMBED_ASSETS dir_inst.startsWith('assets/') ? Assets.getSound(dir_inst, false) : Sound.fromFile(dir_inst) #else Sound.fromFile(dir_inst) #end;
			Cache.audio.set('song://$path/inst', inst);
		}

		if (Cache.audio.get('song://$path/vocals') == null) {
			var dir_player_vocals:String = aliasBullshit('songs/$path/{alias}', ['voices', 'vocals', 'voices-player', 'vocals-player'], '.ogg', ignoreModFiles);
			vocals = dir_player_vocals == null ? null : #if EMBED_ASSETS (dir_player_vocals.startsWith('assets/') ? Assets.getSound(dir_player_vocals, false) : Sound.fromFile(dir_player_vocals)) #else Sound.fromFile(dir_player_vocals) #end;
			Cache.audio.set('song://$path/vocals', vocals);
		}

		if (Cache.audio.get('song://$path/vocals-opponent') == null) {
			var dir_opponent_vocals:String = aliasBullshit('songs/$path/{alias}', ['voices-opponent', 'vocals-opponent'], '.ogg', ignoreModFiles);
			vocalsOpponent = dir_opponent_vocals == null ? null : #if EMBED_ASSETS (dir_opponent_vocals.startsWith('assets/') ? Assets.getSound(dir_opponent_vocals, false) : Sound.fromFile(dir_opponent_vocals)) #else Sound.fromFile(dir_opponent_vocals) #end;
			Cache.audio.set('song://$path/vocals-opponent', vocalsOpponent);
		}

		return {
			inst: inst == null ? Cache.audio.get('song://$path/inst') : inst,
			vocals: vocals == null ? Cache.audio.get('song://$path/vocals') : vocals,
			vocalsOpponent: vocalsOpponent == null ? Cache.audio.get('song://$path/vocals-opponent') : vocalsOpponent,
			instExisted: inst == null,
			vocalsExisted: vocals == null,
			opponentVocalsExisted: vocalsOpponent == null
		};
	}

	public static function getChart(path:String, difficulty:String = 'hard', ignoreModFiles:Bool = false) {
		final dir_chart:String = workingDirectory('songs/$path/$difficulty', '.json', ignoreModFiles);
		if (dir_chart == null)
			return null;
		final dir_type:String = workingDirectory('songs/$path/chart_engine', '.txt', ignoreModFiles);

		final type:String = dir_type == null ? 'its mint engine lmao *nervously wishes it doesnt crash*' : #if EMBED_ASSETS (dir_type.startsWith('assets/') ? Assets.getText(dir_type) : File.getContent(dir_type)) #else File.getContent(dir_type) #end;
		final unresolvedChart:Dynamic = readJson(#if EMBED_ASSETS (dir_chart.startsWith('assets/') ? Assets.getText(dir_chart) : File.getContent(dir_chart)) #else File.getContent(dir_chart) #end);
		switch type.toLowerCase() {
			case 'psych':
				return ChartProcessor.parsePsych(unresolvedChart);
			default:
				return null;
		}

		return null;
	}

	public static function aliasBullshit(path:String, aliases:Array<String>, extension:String, ignoreModFiles:Bool = false) {
		final split:Array<String> = path.split('{alias}');
		if (split.length < 2)
			throw new Exception('Can\'t put aliases into non-template string ("$path" misses "{alias}").');

		for (alias in aliases) {
			final result:String = workingDirectory(split.join(alias), extension, ignoreModFiles);
			if (result != null)
				return result;
		}

		return null;
	}

	public static function readJson(json:String):Dynamic {
		json = json.trim();
		while (!json.endsWith("}"))
			json = json.substr(0, json.length - 1);
		return haxe.Json.parse(json);
	}
}
