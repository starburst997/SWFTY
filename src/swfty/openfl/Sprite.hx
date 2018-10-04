package swfty.openfl;

import haxe.ds.Option;
import haxe.ds.StringMap;

import openfl.display.Tile;
import openfl.display.TileContainer;

class Sprite extends TileContainer {

    public var name:String;
    public var layer:Layer;

    var _childs:StringMap<Sprite>;
    var definition:Option<MovieClipDefinition> = None;

    public static inline function create(layer:Layer, ?definition:MovieClipDefinition) {
        return new Sprite(layer, definition);
    }

    public function new(layer:Layer, definition:MovieClipDefinition) {
        super();

        this.layer = layer;
        this.definition = definition == null ? None : Some(definition);
        _childs = new StringMap();

        switch(this.definition) {
            case Some(definition) :
                // Create children
                for (child in definition.children) {
                    var sprite:Sprite = create(layer, layer.getDefinition(child.id));
                    if (child.name != null) {
                        sprite.name = child.name;
                        _childs.set(child.name, sprite);
                    }

                    sprite.matrix.a = child.a;
                    sprite.matrix.b = child.b;
                    sprite.matrix.c = child.c;
                    sprite.matrix.d = child.d;
                    sprite.matrix.tx = child.tx;
                    sprite.matrix.ty = child.ty;
                    sprite.visible = child.visible;

                    for (shape in child.shapes) {
                        var tile = new Tile(layer.getTile(shape.bitmap));
                        tile.matrix.a = shape.a;
                        tile.matrix.b = shape.b;
                        tile.matrix.c = shape.c;
                        tile.matrix.d = shape.d;
                        tile.matrix.tx = shape.tx;
                        tile.matrix.ty = shape.ty;

                        sprite.addTile(tile);
                    }

                    addTile(sprite);
                }
            case None :  
        }
    }

    public function get(name:String):Sprite {
        return if (_childs.exists(name)) {
            _childs.get(name);
        } else {
            Log.warn('Child: $name does not exists!');
            var sprite = create(layer);
            _childs.set(name, sprite);
            sprite;
        }
    }
}