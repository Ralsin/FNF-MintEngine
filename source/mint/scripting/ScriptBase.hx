package mint.scripting;

class ScriptBase {
	private function new() {
		for (field in Type.getInstanceFields(ScriptBase))
			if (Reflect.isFunction(Reflect.field(this, field)))
				Reflect.setField(this, field, null); // surely nothing will go wrong :clueless:
	}
	/*** Called before anything has initialized. **/
	public dynamic function onCreate(filename:String):Void {}
	/*** Called after everything initialized. **/
	public dynamic function onCreatePost(filename:String):Void {}
	/*** Called every frame before any update. **/
	public dynamic function onUpdate(elapsed:Float):Void {}
	/*** Called every frame after everything was updated. **/
	public dynamic function onUpdatePost(elapsed:Float):Void {}
	/*** Called each countdown tick (3,2,1,0 = Three,Two,One,Go). **/
	public dynamic function onCountdownTick(tick:Int):Void {}
	/*** Called once the song started. **/
	public dynamic function onSongStart():Void {}
	/*** Called once the song ends. **/
	public dynamic function onSongEnd():Void {}
	/*** Called every step hit. **/
	public dynamic function onStepHit(step:Int):Void {}
	/*** Called every beat hit. **/
	public dynamic function onBeatHit(beat:Int):Void {}
	/*** Called every section hit. **/
	public dynamic function onSectionHit(index:Int):Void {}
	/*** Called when the note is about to spawn. Used to set note properties (if length > 0 it's a note that should be held). **/
	public dynamic function onNoteInit(isOpponent:Bool, index:Int, type:Int, length:Float):Void {}
	/*** Called every time note is successfully hit. **/
	public dynamic function onNoteHit(isOpponent:Bool, index:Int, type:Int, length:Float, rating:String):Void {}
	/*** Called every miss. **/
	public dynamic function onNoteMiss(isOpponent:Bool, index:Int, type:Int, length:Float, rating:String):Void {}
	/*** Called every time stats text updates. **/
	public dynamic function onStatsUpdate():Void {}
	/*** Called every time a key is pressed (repeats if held). **/
	public dynamic function onKeyDown(autorepeat:Bool, bind:String, key:String):Void {}
	/*** Called every time a key is released. **/
	public dynamic function onKeyUp(bind:String, key:String):Void {}
	/**
	 * Called when player dies. Has 2 args (scenePhase, count).  
	 * **scenePhase** values (string):  
	 * `death` - passed hp check, before death scene loaded.  
	 * (and unless it was cancelled)  
	 * `load` - death scene loaded.  
	 * `start` - animation started playing.
	 */
	public dynamic function onDeath(scenePhase:String, count:Int):Void {}
	/*** Called when player leaves the song via menu. **/
	public dynamic function onExit():Void {}
	/*** Called when this script is being destroyed (useful for cleanup). **/
	public dynamic function onDestroy():Void {}
}

class HardcodedScript extends ScriptBase {
	public static var enabled(default, set):Bool = false;
	public static var instance:HardcodedScript;
	public function new() {
		super();
		instance = this;
	}
	static function set_enabled(value:Bool) {
		if (MainState.instance.stateStr == 'menus.PlayState') {
			if (value)
				if (instance.onCreate != null)
					instance.onCreate(null);
			else
				if (instance.onDestroy != null)
					instance.onDestroy();
		}
		return enabled = value;
	}
}
