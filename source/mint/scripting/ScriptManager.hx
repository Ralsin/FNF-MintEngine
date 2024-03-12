package mint.scripting;

import hscript.*;

class ScriptManager {
	static var parser(default, null):Parser;
	static var interpreter(default, null):Interp;
	static function __init__() {
		parser = new Parser();
		interpreter = new Interp();

		interpreter.variables.set('ScriptBase', ScriptBase);
		interpreter.variables.set('Menu', extendable.Menu);
		interpreter.variables.set('ScreenLog', mint.ui.ScreenLog);
		interpreter.variables.set('log', mint.ui.ScreenLog.log);
	}
	public function new(path:String) {
		var expression = parser.parseString(api.MintFileManager.getText(path), path);
		trace(interpreter.execute(expression));
	}
}