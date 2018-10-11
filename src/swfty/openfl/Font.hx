package swfty.openfl;

import haxe.ds.IntMap;

class Font {

    public var definition:FontDefinition;
    
    var layer:Layer;
    var tiles:IntMap<Character>;

    public static inline function create(layer:Layer, definition:FontDefinition) {
        return new Font(layer, definition);
    }

    public function new(layer:Layer, definition:FontDefinition) {
        this.layer = layer;
        this.definition = definition;

        tiles = new IntMap();
        definition.characters.iter(char -> {
            tiles.set(char.id, char);
        });
    }

    public inline function get(code:Int) {
        return tiles.get(code);
    }

    public inline function has(code:Int) {
        return tiles.exists(code);
    }
}