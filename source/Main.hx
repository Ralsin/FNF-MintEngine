class Main extends openfl.display.Sprite {
	public function main() {
		#if (hl && release)
		hl.UI.closeConsole();
		#end
		openfl.Lib.current.addChild(new Main());
	}
	public function new() {
		super();
		addChild(new Game(1280, 720)); // TODO: remember last window size and add "reset window size" option
	}
}