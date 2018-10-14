package swfty.openfl;

import haxe.ds.Option;
import haxe.ds.StringMap;

import openfl.geom.ColorTransform;
import openfl.display.Tile;
import openfl.display.TileContainer;

class Sprite extends TileContainer {

    public var name:String;
    public var layer:Layer;

    var _childs:StringMap<Sprite>;
    var _texts:StringMap<Text>;
    var definition:Option<MovieClipDefinition> = None;

    public static inline function create(layer:Layer, ?definition:MovieClipDefinition) {
        return new Sprite(layer, definition);
    }

    public function new(layer:Layer, definition:MovieClipDefinition) {
        super();

        this.layer = layer;
        this.definition = definition == null ? None : Some(definition);
        _childs = new StringMap();
        _texts = new StringMap();

        switch(this.definition) {
            case Some(definition) :
                // Create children
                for (child in definition.children) {
                    if (child.text != null) {
                        var text = Text.create(layer, child.text);

                        text.matrix.a = child.a;
                        text.matrix.b = child.b;
                        text.matrix.c = child.c;
                        text.matrix.d = child.d;
                        text.matrix.tx = child.tx;
                        text.matrix.ty = child.ty;
                        text.visible = child.visible;

                        if (child.name != null) {
                            text.name = child.name;
                            _texts.set(child.name, text);
                        }

                        addTile(text);
                    } else {
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
                        sprite.alpha = child.alpha;
                        sprite.visible = child.visible;

                        if (child.blendMode != Normal) sprite.blendMode = child.blendMode;
                        if (child.color != null) sprite.colorTransform = new openfl.geom.ColorTransform(child.color.r, child.color.g, child.color.b, 1.0, child.color.rAdd, child.color.gAdd, child.color.bAdd, 0.0);

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

    public function setText(name:String, text:String) {

    }
}