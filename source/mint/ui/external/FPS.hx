package mint.ui.external;

class FPS extends openfl.text.TextField {
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 4, y:Float = 4, color:Int = 0xFFFFFF) {
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
		autoSize = LEFT;
		text = "FPS: ";
		blendMode = SCREEN;

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void {
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
			times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount)
			text = "FPS: " + currentFPS;

		cacheCount = currentCount;
	}
}
