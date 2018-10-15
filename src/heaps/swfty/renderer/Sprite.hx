package heaps.swfty.renderer;

import haxe.ds.Option;
import haxe.ds.StringMap;

class Sprite {
    
    public var name:String;
    public var layer:Layer;
    
    var definition:Option<MovieClipDefinition> = None;

    public static inline function create(layer:Layer, ?definition:MovieClipDefinition) {
        return new Sprite(layer, definition);
    }

    public function new(layer:Layer, definition:MovieClipDefinition) {
        this.layer = layer;
        this.definition = definition == null ? None : Some(definition);
    }
}