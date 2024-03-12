package mint;

typedef ModMetadata = {
	var displayName:String;
	var id:String;
	var options:Array<MetaOption>;
}

typedef MetaOption = {
	var type:String; // bool, float, string
	var defaultValue:Dynamic;
	var ?values:Array<Dynamic>;
	var ?stepSize:Float;
}