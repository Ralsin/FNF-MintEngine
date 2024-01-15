package mint.ui.external;

class Memory extends openfl.text.TextField {
	@:noCompletion private var lastTick:Float = -0.5;
	@:noCompletion private var curTick:Float = 0.0;

	public function new(x:Float = 4, y:Float = 18, color:Int = 0xFFFFFF) {
		super();

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
		autoSize = LEFT;
		text = 'Memory: 0 MB';
		blendMode = SCREEN;
	}

	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void {
		curTick += deltaTime;
		if (curTick < lastTick + .5)
			return;
		lastTick += .5;
		text = 'Memory: ' + Math.floor(Math.abs(Std.int(hl.Gc.stats().currentMemory) / 1048576)*10)*.1 + ' MB'; // Shadow Mario, RAM uses MB which is not bit, its a byte
	}
}
