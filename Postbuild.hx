// idk im lazy to write working batch code
package;

class Postbuild {
	public static function main():Void {
		for (arg in Sys.args())
			switch arg {
				case "--cleanup":
					cleanup();
			}
	}

	static function cleanup():Void {
		var cleanupList = [
			"export/release/hl/bin/fmt.hdll",
			"export/release/hl/bin/icon.ico",
			"export/release/hl/bin/mysql.hdll",
			"export/release/hl/bin/ssl.hdll",
			"export/release/hl/bin/uv.hdll"
		];
		if (sys.FileSystem.exists("Project.xml"))
			for (projectNodes in Xml.parse(sys.io.File.getContent("Project.xml")).elementsNamed("project"))
				for (defineFlag in projectNodes.elementsNamed("define"))
					if (defineFlag.get("name") == "EMBED_ASSETS")
						cleanupList = cleanupList.concat(["export/release/hl/bin/assets/", "export/release/hl/bin/manifest/"]);
		for (path in cleanupList)
			if (sys.FileSystem.exists(path))
				if (sys.FileSystem.isDirectory(path)) {
					_clearFolder(path);
				} else
					sys.FileSystem.deleteFile(path);
	}

	static function _clearFolder(path:String):Void {
		for (_path in sys.FileSystem.readDirectory(path)) {
			if (sys.FileSystem.isDirectory(path+_path)) {
				_clearFolder(path+_path+'/');
			} else
				sys.FileSystem.deleteFile(path+_path);
		}
		sys.FileSystem.deleteDirectory(path);
	}
}
