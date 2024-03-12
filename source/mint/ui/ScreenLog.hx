package mint.ui;

import openfl.text.TextField;
import openfl.display.Sprite;

class ScreenLog extends Sprite {
	public static var display(default, null):Sprite = new Sprite();
	public static var logs:Array<TextField> = [];

	/**
	 * Logs info onto the screen.
	 */
	public static function log(message:String, type:LogType = INFO) {
		trace('[${type.getName()}] $message');

		final newLog:TextField = new TextField();
		newLog.x = 8;
		flixel.tweens.FlxTween.tween(newLog, {alpha: 0.}, 2., {
			startDelay: 3.,
			onComplete: (twn) -> {
				display.removeChild(newLog);
				logs.remove(newLog);
			}
		});
		onLog(newLog, message, type);
		newLog.selectable = false;
		newLog.mouseEnabled = false;
		newLog.y += Main.statsLabel.height;

		if (logs.length > 24)
			while (logs.length > 23) {
				final log = logs.shift();
				flixel.tweens.FlxTween.cancelTweensOf(log);
				display.removeChild(log);
			}

		for (i in 0...logs.length) {
			final log = logs[i];
			if (log == null)
				continue;
			log.y += newLog.textHeight + 4.;
		}

		logs.push(newLog);
		display.addChild(newLog);
	}

	public dynamic static function onLog(logObj:TextField, message:String, type:LogType) {
		final color:Int = switch type {
			case DEPRECATION: 0xFF9900;
			case ERROR: 0xDD0000;
			default: 0xFFFFFF;
		}
		logObj.defaultTextFormat = new openfl.text.TextFormat("_sans", 16, color);
		logObj.autoSize = LEFT;
		logObj.text = message;
		logObj.blendMode = SCREEN;
	}
}

enum LogType {
	INFO;
	DEPRECATION;
	ERROR;
	CRITICAL_ERROR;
}
