import haxe.ds.Option;
import haxe.ds.StringMap;

import openfl.display.TileContainer;

class SWFTYSprite extends TileContainer {

    public var name:String;

    var _childs:StringMap<SWFTYSprite>;

    public static inline function create() {
        return new SWFTYSprite();
    }

    public function new() {
        super();

        _childs = new StringMap();
    }

    public function getChild(name:String):SWFTYSprite {
        return if (_childs.exists(name)) {
            _childs.get(name);
        } else {
            Log.warn('Child: $name does not exists!');
            var sprite = create();
            _childs.set(name, sprite);
            sprite;
        }
    }
}