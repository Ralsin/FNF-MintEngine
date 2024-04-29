package funkin.api;

import haxe.CallStack.StackItem;

class CrashHandler {
	public static function getFilePos(stackItems:Array<StackItem>, limit:Int = 5):Array<String> {
		var i = 0;
		final r:Array<String> = [];
		for (item in stackItems) {
			if (++i > limit)
				return r;

			switch item {
				case FilePos(s, file, line, column):
					r.push(file+':'+line+'\n');
				default:
					trace(item);
			}
		}
		return r;
	}
	public static function getFirstFilePos(stackItems:Array<StackItem>):Null<String> {
		for (item in stackItems)
			switch item {
				case FilePos(s, file, line, column):
					return file+':'+line;
				default:
					trace(item);
			}
		return null;
	}
}