package mint.ui.external;

import haxe.CallStack.StackItem;

class CrashHandler {
	public static var jokeLines:Array<String> = [
		'How unfortunate.',
		'Fun fact: your ip is '+Math.ceil(Math.random()*255.)+'.'+Math.ceil(Math.random()*255.)+'.'+Math.ceil(Math.random()*255.)+'.'+Math.ceil(Math.random()*255.),
		'You know what that means.. FISH!🐟',
		'I order you to breath consciously.',
		'Meow meow meow meow meow meow meow meow meow meow.',
		'Your catnip was delivered.',
		'Is your fridge running?',
		'mewo.',
		':lumin_horror:',
		'okay what the actual-',
		'Did you know that in terms of\nmale human and female pokemon...',
		'I\'m sorry :p'
	];

	public static function errorPopup(msg:String) {
		#if hl
		hl.UI.dialog('Error!', mint.helpers.Random.array(jokeLines)+'\n\nError: '+msg+'\nPlease report it at https://github.com/Ralsin/FNF-MintEngine or @ralsi_', cast 0 | 1 << 1);
		#elseif cpp
		#end
	}

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

enum InfoLogType {
	INFO;
	DEPRECATION;
	ERROR;
	CRITICAL_ERROR;
}
