package source;

class ErrorDialogue {
    private static final flags:haxe.EnumFlags<hl.UI.DialogFlags> = cast 0 | 1 << 1; // this shit is dumb, what were they smoking while making this class???

    private var message:String = '';
    public function new(message: String, exit:Bool = false) {
        this.message = '\nErm, what the scallop!?\n\n'+
                        message+
                        '\n\n> You should send this to @ralsi_ at either Discord or Twitter!!';

        if (exit) return Sys.exit(1);
    }
    public function show() {
		hl.UI.dialog('Error!', message, flags);
    }
}