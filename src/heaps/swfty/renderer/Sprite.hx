package heaps.swfty.renderer;

import haxe.ds.Option;
import haxe.ds.StringMap;

class Sprite extends h2d.Sprite {

    public var layer:Layer;
    public var tile:h2d.Tile;
    public var color:h3d.Vector;

    public var r:Float = 1.0;
    public var g:Float = 1.0;
    public var b:Float = 1.0;

    // TODO: Listen to remove child and remove from array
    var sprites:Array<Sprite>;

    var _parent:Sprite;
    var _childs:StringMap<Sprite>;
    var _texts:StringMap<Text>;
    var definition:Option<MovieClipDefinition> = None;
    var renders:Array<Float->Void>;

    public static inline function create(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipDefinition, ?parent) {
        return new Sprite(layer, tile, definition, parent);
    }

    public function new(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipDefinition, ?parent) {
        this.tile = tile;
        this.layer = layer;
        this.definition = definition == null ? None : Some(definition);
        
        color = new h3d.Vector(1, 1, 1, 1);

        sprites = [];
        renders = [];
        _childs = new StringMap();
        _texts = new StringMap();
        
        super(parent);

        switch(this.definition) {
            case Some(definition) :
                
                // Create children
                for (child in definition.children) {
                    if (child.text != null) {
                        var text = Text.create(layer, child.text);

                        text.x = _x(child.tx);
                        text.y = _y(child.ty);
                        text.scaleX = _scaleX(child.a, child.b);
                        text.scaleY = _scaleY(child.c, child.d);
                        text.rotation = _rotation(child.b, child.c, child.d);

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

                        sprite.x = _x(child.tx);
                        sprite.y = _y(child.ty);
                        sprite.scaleX = _scaleX(child.a, child.b);
                        sprite.scaleY = _scaleY(child.c, child.d);
                        sprite.rotation = _rotation(child.b, child.c, child.d);

                        sprite.alpha = child.alpha;
                        sprite.visible = child.visible;

                        if (child.color != null) {
                            sprite.r = child.color.r;
                            sprite.g = child.color.g;
                            sprite.b = child.color.b;
                        }

                        for (shape in child.shapes) {
                            var tile = create(layer, layer.getTile(shape.bitmap));

                            tile.x = _x(shape.tx);
                            tile.y = _y(shape.ty);
                            tile.scaleX = _scaleX(shape.a, shape.b);
                            tile.scaleY = _scaleY(shape.c, shape.d);
                            tile.rotation = _rotation(shape.b, shape.c, shape.d);

                            sprite.addTile(tile);
                        }

                        addTile(sprite);
                    }
                }
            case None :  
        }
    }

    override function calcAbsPos() {
        super.calcAbsPos();

        // Calculate alpha and color
		if( _parent == null ) {
			color.r = r;
			color.g = g;
			color.b = b;
			color.w = alpha;
		} else {
            color.r = r * _parent.color.r;
			color.g = g * _parent.color.g;
			color.b = b * _parent.color.b;
            color.w = alpha * _parent.color.w;
		}
	}

    inline function _x(tx:Float) {
        return tx;
    }

    inline function _y(ty:Float) {
        return ty;
    }

    inline function _scaleX(a:Float, b:Float) {
        return if (b == 0)
            a;
        else
            Math.sqrt(a * a + b * b);
    }

    inline function _scaleY(c:Float, d:Float) {
        return if (c == 0)
            d;
        else    
            Math.sqrt(c * c + d * d);
    }

    inline function _rotation(b:Float, c:Float, d:Float) {
        return if (b == 0 && c == 0)
            0.0;
        else {
            var radians = Math.atan2(d, c) - (Math.PI / 2);
            radians;
        }
    }

    public function addTile(sprite:Sprite) {
        sprites.push(sprite);

        sprite._parent = this;

        addChild(sprite);
    }

    public function update(dt:Float) {
        for (sprite in sprites) {
            sprite.update(dt);
        }

        if (tile != null) {
            /*if (posChanged)*/ syncPos();
            layer.drawTile(Std.int(_x(absX)), Std.int(_y(absY)), _scaleX(matA, matB), _scaleY(matC, matD), _rotation(matB, matC, matD), color, tile);
        }

        for (f in renders) f(dt);
    }

    public function addRender(f:Float->Void) {
        renders.push(f);
    }

    public function removeRender(f:Float->Void) {
        renders.remove(f);
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