package funkin.api;

import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;
import haxe.Serializer;
import haxe.Unserializer;

class SaveManager {
	@:noPrivateAccess static var saves:Map<String, Save>;
	public static var save(default, null):Save;

	static function __init__() {
		if (!FileSystem.exists('./saves/') || !FileSystem.isDirectory('./saves/'))
			FileSystem.createDirectory('./saves/');
		saves = [];
		bind('Main');
		save = saves.get('Main');
		for (saveName in FileSystem.readDirectory('./saves/'))
			if (!FileSystem.isDirectory('./saves/' + saveName))
				bind(StringTools.replace(saveName, '.bin', ''));

		save.data.test = 'mewo';
		save.save();
	}

	public static function bind(name:String) {
		final path:String = './saves/' + name + '.bin';
		if (FileSystem.exists(path)) {
			var b = File.getBytes(path);
			var bytes = Bytes.alloc(Math.ceil(b.length * .5));
			for (p in 0...bytes.length)
				bytes.set(p, b.get(p * 2) - b.get(p * 2 + 1));
			saves.set(name, new Save(path, Unserializer.run(bytes.toString())));
			bytes = null;
		} else
			saves.set(name, new Save(path));
	}
}

class Save {
	var path:String;

	public var data:Dynamic = {};

	public function new(path:String, ?data:Dynamic) {
		this.path = path;
		if (data != null)
			this.data = data;
	}

	public function save() {
		var b = Bytes.ofString(Serializer.run(data));
		var bytes = Bytes.alloc(b.length * 2);
		for (p in 0...b.length) {
			var shift = Math.floor(Math.random() * 255);
			bytes.set(p * 2, b.get(p) + shift);
			bytes.set(p * 2 + 1, shift);
		}
		var out = File.write(path, true);
		out.write(bytes);
		out.close();
		bytes = null;
	}
}
