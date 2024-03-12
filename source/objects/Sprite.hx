package objects;

import flixel.FlxSprite;
import api.MintFileManager;

var useGPU:Bool = true;

class Sprite extends FlxSprite {
    public var tag(default, null):String;
    public function new(?tag:String, path:String = 'toastie', x:Float = 0., y:Float = 0.) {
        super(x, y);
        loadGraphic(MintFileManager.getImage(path));
        if (tag == null)
			tag = mint.helpers.Random.addStringId(path, 16);
        // SpritesManager.add(tag, path, this);
    }
}

// class SpritesManager {
//     public static var counts:Map<String,Int> = [];
//     public static var tagPath:Map<String,String> = [];
//     public static var objects:Map<String,Sprite> = [];
// 	public static function add(tag:String, path:String, obj:Sprite):Void {
// 		tagPath.set(tag, path);
// 		counts[path] += 1;
// 		objects.set(tag, obj);
//     }
//     public static function destroy(tag:String) {
//         objects[tag].destroy();
//         objects.remove(tag);
// 		var path:String = tagPath[tag];
//         counts[path] -= 1;
//         if (counts[path] < 1)
//             counts.remove(path);
//     }
// }
