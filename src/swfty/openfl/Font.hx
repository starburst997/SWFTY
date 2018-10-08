package swfty.openfl;

import haxe.ds.IntMap;

class Font {

    public var definition:FontDefinition;
    
    var layer:Layer;
    var tiles:IntMap<Int>;

    public static inline function create(layer:Layer, definition:FontDefinition, tiles:IntMap<Int>) {
        return new Font(layer, definition, tiles);
    }

    public function new(layer:Layer, definition:FontDefinition, tiles:IntMap<Int>) {
        this.layer = layer;
        this.definition = definition;

        this.tiles = tiles;
    }

    public function get(code:Int) {
        return tiles.get(code);
    }

    public function has(code:Int) {
        return tiles.exists(code);
    }
}