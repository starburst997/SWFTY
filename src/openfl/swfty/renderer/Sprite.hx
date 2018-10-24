package openfl.swfty.renderer;

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
    var definition:Option<MovieClipType> = None;

    public static inline function create(layer:Layer, definition:Option<MovieClipType>) {
        return new Sprite(layer, definition);
    }

    public function new(layer:Layer, definition:Option<MovieClipType>) {
        super();

        this.layer = layer;
        this.definition = definition;

        _childs = new StringMap();
        _texts = new StringMap();

        switch(this.definition) {
            case Some(definition) :
                // Create children
                for (child in definition.children) {
                    switch(child.text) {
                        case Some(text):
                            var text = Text.create(layer, text);

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
                        case None:
                            var sprite:Sprite = create(layer, child.mc);

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

                            // This will add drawCalls, so big no no unless you really want them
                            #if allowBlendMode
                            if (child.blendMode != Normal && child.blendMode != null) {
                                sprite.blendMode = child.blendMode;
                            }
                            #end

                            switch(child.color) {
                                case Some(color) : 
                                    sprite.colorTransform = new openfl.geom.ColorTransform(color.r, color.g, color.b, 1.0, color.rAdd, color.gAdd, color.bAdd, 0.0);
                                case None : 
                            }

                            for (shape in child.shapes) {
                                var tile = new Tile(layer.getTile(shape.bitmap.id));
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
            var sprite = create(layer, None);
            _childs.set(name, sprite);
            sprite;
        }
    }

    public function setText(name:String, text:String) {

    }
}