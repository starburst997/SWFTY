package openfl.swfty.renderer;

import openfl.swfty.renderer.Layer;

typedef EngineSprite = openfl.display.TileContainer;
typedef EngineBitmap = openfl.display.Tile;

class FinalSprite extends BaseSprite {

    public static inline function create(layer:Layer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:Layer, ?definition:MovieClipType, ?linkage:String) {
        super(layer, definition, linkage);
    }

    public override function addSprite(sprite:FinalSprite) {
        sprite._parent = this;
        super.addSprite(sprite);
        addTile(sprite);
    }

    public override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    public override function addBitmap(bitmap:EngineBitmap) {
        addTile(bitmap);
    }

    public override function removeBitmap(bitmap:EngineBitmap) {
        removeTile(bitmap);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:EngineLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.matrix.a = a;
        this.matrix.b = b;
        this.matrix.c = c;
        this.matrix.d = d;
        this.matrix.tx = tx;
        this.matrix.ty = ty;
    }

    public inline function color(r:Int, g:Int, b:Int) {
        this.colorTransform = new openfl.geom.ColorTransform(r/255, g/255, b/255, 1.0);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        while(this.numTiles > 0) this.removeTileAt(0);
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.matrix.a = a;
        this.matrix.b = b;
        this.matrix.c = c;
        this.matrix.d = d;
        this.matrix.tx = tx;
        this.matrix.ty = ty;
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        this.colorTransform = new openfl.geom.ColorTransform(r, g, b, 1.0, rAdd, gAdd, bAdd, 0.0);
    }

    public inline function resetColor() {
        this.colorTransform = null;
    }

    public inline function blend(mode:BlendMode) {
        this.blendMode = mode;
    }

    public inline function resetBlend() {
        this.blendMode = null;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, visible)
abstract Sprite(FinalSprite) from FinalSprite to FinalSprite {

    public static inline function create(layer:Layer, ?definition:MovieClipType, ?linkage:String):Sprite {
        return new FinalSprite(layer, definition, linkage);
    }

    public var parent(get, never):Sprite;
    public inline function get_parent():Sprite {
        return this.getParent();
    }
    
    public inline function add(sprite:Sprite) {
        this.addSprite(sprite);
    }

    public inline function remove(sprite:Sprite) {
        this.removeSprite(sprite);
    }

    public inline function get(name:String):Sprite {
        return this.get(name);
    }

    public inline function getText(name:String):Text {
        return this.getText(name);
    }
}