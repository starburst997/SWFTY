package heaps.swfty.renderer;

import haxe.ds.StringMap;

class Sprite extends h2d.Object {

    public var layer:Layer;
    public var tile:h2d.Tile;
    public var color:h3d.Vector;

    public var r:Float = 1.0;
    public var g:Float = 1.0;
    public var b:Float = 1.0;

    public var og:Bool = false;

    // TODO: Listen to remove child and remove from array
    var sprites:Array<Sprite>;

    // For reload if definition didn't exists
    var linkage:String;

    var _lastAlpha = 1.0;
    var _parent:Sprite;
    var _childs:StringMap<Sprite>;
    var _texts:StringMap<Text>;
    var definition:Null<MovieClipType>;
    var renders:Array<Float->Void>;

    public static inline function create(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String, ?parent:h2d.Object):Sprite {
        return new Sprite(layer, tile, definition, linkage, parent);
    }

    public function new(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String, ?parent:h2d.Object) {
        this.tile = tile;
        this.layer = layer;
        this.linkage = linkage;
        
        color = new h3d.Vector(1, 1, 1, 1);

        sprites = [];
        renders = [];
        _childs = new StringMap();
        _texts = new StringMap();
        
        super(parent);

        load(definition);
    }

    public function load(definition:MovieClipType) {
        this.definition = definition;

        var childs = sprites;
        sprites = [];

        // Clear tiles
        removeChildren();

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

                text.x = _x(child.tx);
                text.y = _y(child.ty);
                text.scaleX = _scaleX(child.a, child.b, child.c, child.d);
                text.scaleY = _scaleY(child.a, child.b, child.c, child.d);
                text.rotation = _rotation(child.b, child.c, child.d);

                text.visible = child.visible;

                addTile(text);
            } else { 
                var sprite:Sprite = if (!child.name.empty() && _childs.exists(child.name)) {
                    _childs.get(child.name).load(child.mc);
                } else {
                    var sprite:Sprite = create(layer, child.mc);
                    sprite.og = true;

                    if (!child.name.empty()) {
                        sprite.name = child.name;
                        _childs.set(child.name, sprite);
                    }
                    sprite;
                }

                sprite.x = _x(child.tx);
                sprite.y = _y(child.ty);
                sprite.scaleX = _scaleX(child.a, child.b, child.c, child.d);
                sprite.scaleY = _scaleY(child.a, child.b, child.c, child.d);
                sprite.rotation = _rotation(child.b, child.c, child.d);

                sprite.alpha = child.alpha;
                sprite.visible = child.visible;

                if (child.color != null) {
                    sprite.r = child.color.r;
                    sprite.g = child.color.g;
                    sprite.b = child.color.b;
                }

                for (shape in child.shapes) {
                    var tile = create(layer, layer.getTile(shape.bitmap.id));
                    tile.og = true;

                    tile.x = _x(shape.tx);
                    tile.y = _y(shape.ty);
                    tile.scaleX = _scaleX(shape.a, shape.b, child.c, child.d);
                    tile.scaleY = _scaleY(child.a, child.b, shape.c, shape.d);
                    tile.rotation = _rotation(shape.b, shape.c, shape.d);

                    sprite.addTile(tile);
                }

                addTile(sprite);
            }
        }

        // Re-add non-og tile
        for (child in childs) {
            if (!child.og) {
                child.reload();

                // TODO: Usually non-og sprites are added on top, figure out a better way to preserve order
                addTile(child);
            }
        }

        return this;
    }

    override function removeChildren() {
        super.removeChildren();
        sprites = [];
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

    inline function _scaleX(a:Float, b:Float, c:Float, d:Float) {
        return if (b == 0)
            a;
        else
            // TODO: Figure out why I had to do that
            Math.sqrt(a * a + b * b) * (a < 0 ? -1 : 1) * (d < 0 ? -1 : 1);
    }

    inline function _scaleY(a:Float, b:Float, c:Float, d:Float) {
        return if (c == 0)
            d;
        else
            // TODO: Why is this working?
            Math.sqrt(c * c + d * d);// * (b < 0 ? -1 : 1) * (c < 0 ? -1 : 1);
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

    public function removeTile(sprite:Sprite) {
        sprites.remove(sprite);

        sprite._parent = null;
        sprite.remove();
    }

    public function update(dt:Float) {
        // Hack for alpha change
        if (_lastAlpha != alpha) posChanged = true;
        _lastAlpha = alpha;

        for (sprite in sprites) {
            sprite.update(dt);
        }

        for (f in renders) f(dt);
    }

    public function render(ctx) {
        drawRec(ctx);
    }

    override function draw(ctx) {
        if (tile != null) {
            layer.drawTile(Std.int(_x(absX)), Std.int(_y(absY)), _scaleX(matA, matB, matC, matD), _scaleY(matA, matB, matC, matD), _rotation(matB, matC, matD), color, tile);
        }
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