import openfl.display.Tile;
import haxe.ds.Option;
import haxe.ds.StringMap;

import SWFTYExporter;

import openfl.display.TileContainer;

class SWFTYSprite extends TileContainer {

    public var name:String;
    public var layer:SWFTYLayer;

    var _childs:StringMap<SWFTYSprite>;
    var definition:Option<MovieClipDefinition> = None;

    public static inline function create(layer:SWFTYLayer, ?definition:MovieClipDefinition) {
        return new SWFTYSprite(layer, definition);
    }

    public function new(layer:SWFTYLayer, definition:MovieClipDefinition) {
        super();

        this.layer = layer;
        this.definition = definition == null ? None : Some(definition);
        _childs = new StringMap();

        switch(this.definition) {
            case Some(definition) :
                // Create children
                for (child in definition.children) {
                    var sprite:SWFTYSprite = create(layer, layer.getDefinition(child.id));
                    if (child.name != null) {
                        sprite.name = child.name;
                        _childs.set(child.name, sprite);
                    }

                    sprite.x = child.x;
                    sprite.y = child.y;
                    sprite.scaleX = child.scaleX;
                    sprite.scaleY = child.scaleY;
                    sprite.rotation = child.rotation;
                    sprite.visible = child.visible;

                    for (shape in child.shapes) {
                        var tile = new Tile(layer.getTile(shape.bitmap), shape.x, shape.y, shape.scaleX, shape.scaleY, shape.rotation, 0, 0);
                        sprite.addTile(tile);
                    }

                    addTile(sprite);
                }
            case None :  
        }
    }

    public function get(name:String):SWFTYSprite {
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