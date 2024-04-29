package funkin.math;

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

	public static inline function array(a:Array<Any>) {
		return a[Math.floor(Math.random() * a.length)];
	}

	public static inline function int(min:Int = 0, max:Int = 1):Int {
		return Math.ceil(Math.random()*(max-min)+min);
	}

	public static inline function float(min:Float = 0., max:Float = 1.):Float {
		return Math.random()*(max-min)+min;
	}

	public static inline function intArray(min:Int = 0, max:Int = 1, limit:Int = 4):Array<Int> {
		return [for (i in 0...limit) int(min, max)];
	}

	public static inline function floatArray(min:Float = 0., max:Float = 1., limit:Int = 4):Array<Float> {
		return [for (i in 0...limit) float(min, max)];
	}
}
