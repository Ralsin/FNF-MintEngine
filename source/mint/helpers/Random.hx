package mint.helpers;

using StringTools;

class Random {
	static final stringRandom:String = 'abcdefghijklmnopqrstuvwxyz01234567890123456789';
	static final stringRandomLength:Int = stringRandom.length;
	static final stringRandomIncludingCapital:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789';
	static final stringRandomIncludingCapitalLength:Int = stringRandomIncludingCapital.length;
    public static inline function stringId(length:Int = 6, includeCapitalCharacters:Bool = true):String {
        var str:String = '';
        includeCapitalCharacters ? {
			for (i in 0...length)
				str += stringRandom.charAt(Math.floor(Math.random() * stringRandomLength));
        } : {
			for (i in 0...length)
				str += stringRandomIncludingCapital.charAt(Math.floor(Math.random() * stringRandomIncludingCapitalLength));
        }
        return str;
    }
	public static function addStringId(str:String, length:Int = 6, includeCapitalCharacters:Bool = true) {
		includeCapitalCharacters ? {
			for (i in 0...length)
				str += stringRandom.charAt(Math.floor(Math.random() * stringRandomLength));
		} : {
			for (i in 0...length)
				str += stringRandomIncludingCapital.charAt(Math.floor(Math.random() * stringRandomIncludingCapitalLength));
		}
		return str;
    }
}