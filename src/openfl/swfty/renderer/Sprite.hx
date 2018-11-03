package openfl.swfty.renderer;

import haxe.ds.StringMap;

import openfl.geom.ColorTransform;
import openfl.display.Tile;
import openfl.display.TileContainer;

class Sprite extends TileContainer {

    public var og:Bool = false;

    public var name:String;
    public var layer:Layer;

    // For reload if definition didn't exists
    var linkage:String;

    var _childs:Array<Sprite>;
    var _names:StringMap<Sprite>;
    var _texts:StringMap<Text>;
    var definition:Null<MovieClipType>;

    public static inline function create(layer:Layer, ?definition:MovieClipType, ?linkage:String) {
        return new Sprite(layer, definition, linkage);
    }

    public function new(layer:Layer, ?definition:MovieClipType, ?linkage:String) {
        super();

        this.layer = layer;
        this.linkage = linkage;
        
        _childs = [];
        _names = new StringMap();
        _texts = new StringMap();
    
        load(definition);
    }

    public function load(definition:MovieClipType) {
        this.definition = definition;
        
        var childs = _childs;
        _childs = [];

        // Clear tiles
        while(numTiles > 0) removeTileAt(0);

        if (definition == null) return this;

        // Create children
        for (child in definition.children) {
            if (child.text != null) {
                var text:Text = if (!child.name.empty() && _texts.exists(child.name)) {
                    _texts.get(child.name).loadText(child.text);
                } else {
                    var text:Text = Text.create(layer, child.text);
                    text.og = true;

                    if (!child.name.empty()) {
                        text.name = child.name;
                        _texts.set(child.name, text);
                    }
                    text;
                }
                
                text.matrix.a = child.a;
                text.matrix.b = child.b;
                text.matrix.c = child.c;
                text.matrix.d = child.d;
                text.matrix.tx = child.tx;
                text.matrix.ty = child.ty;
                text.visible = child.visible;

                add(text);
            } else {
                var sprite:Sprite = if (!child.name.empty() && _names.exists(child.name)) {
                    _names.get(child.name).load(child.mc);
                } else {
                    var sprite:Sprite = create(layer, child.mc);
                    sprite.og = true;

                    if (!child.name.empty()) {
                        sprite.name = child.name;
                        _names.set(child.name, sprite);
                    }
                    sprite;
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
                } else {
                    sprite.blendMode = null;
                }
                #end

                if (child.color != null) {
                    var color = child.color;
                    sprite.colorTransform = new openfl.geom.ColorTransform(color.r, color.g, color.b, 1.0, color.rAdd, color.gAdd, color.bAdd, 0.0);
                } else {
                    sprite.colorTransform = null;
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

                add(sprite);
            }
        }

        // Re-add non-og tile
        for (child in childs) {
            if (!child.og) {
                child.reload();

                // TODO: Usually non-og sprites are added on top, figure out a better way to preserve order
                add(child);
            }
        }
        
        return this;
    }

    public function reload() {
        if (this.definition != null && layer.hasDefinition(this.definition.id)) {
            var definition = layer.getDefinition(this.definition.id);
            load(definition);
        } else if (linkage != null && layer.hasMC(linkage)) {
            var definition = layer.getMC(linkage);
            load(definition);
        }
    }

    public inline function add(sprite:Sprite) {
        _childs.push(sprite);
        addTile(sprite);
    }

    public inline function remove(sprite:Sprite) {
        _childs.remove(sprite);
        removeTile(sprite);
    }

    public function get(name:String):Sprite {
        return if (_names.exists(name)) {
            _names.get(name);
        } else {
            Log.warn('Child: $name does not exists!');
            var sprite = create(layer);
            _names.set(name, sprite);
            sprite;
        }
    }

    public function getText(name:String):Text {
        return if (_texts.exists(name)) {
            _texts.get(name);
        } else {
            Log.warn('Text: $name does not exists!');
            var text = Text.create(layer);
            _texts.set(name, text);
            text;
        }
    }
}