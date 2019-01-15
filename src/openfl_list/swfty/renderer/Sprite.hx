package openfl_list.swfty.renderer;

import openfl.geom.Matrix;

typedef EngineSprite = openfl.display.Sprite;
typedef EngineBitmap = openfl.display.Bitmap;

@:keepSub // Fix DCE=full
class FinalSprite extends BaseSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        super(layer, definition, linkage);
    }

    override function refresh() {
        
    }

    override function set__name(name:String) {
        if (_parent != null) {
            @:privateAccess _parent._names.set(name, this);
        }

        this.name = name;
        
        return super.set__name(name);
    }

    public override function calcBounds(?relative:BaseSprite):Rect {
        var rect = this.getBounds(relative == null ? this : relative);
        return {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        }
    }

    public override function top() {
        if (this.parent != null) parent.setChildIndex(this, parent.numChildren - 1);
    }

    public override function bottom() {
        if (this.parent != null) parent.setChildIndex(this, 0);
    }

    public override function addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        sprite._parent = this;
        super.addSpriteAt(sprite, index);
        addChildAt(sprite, index);
    }

    public override function addSprite(sprite:FinalSprite) {
        sprite._parent = this;
        super.addSprite(sprite);
        addChild(sprite);
    }

    public override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeChild(sprite);
    }

    public override function addBitmap(bitmap:EngineBitmap) {
        addChild(bitmap);
    }

    public override function removeBitmap(bitmap:EngineBitmap) {
        removeChild(bitmap);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.transform.matrix = new Matrix(a, b, c, d, tx, ty);
    }

    public inline function color(r:Int, g:Int, b:Int) {
        this.transform.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, 1.0);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        while(this.numChildren > 0) this.removeChildAt(0);
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.transform.matrix = new Matrix(a, b, c, d, tx, ty);
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        this.transform.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, 1.0, rAdd, gAdd, bAdd, 0.0);
    }

    public inline function resetColor() {
        this.transform.colorTransform = new openfl.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0);
    }

    public inline function blend(mode:BlendMode) {
        #if (openfl >= "8.4.0")
        this.blendMode = mode;
        #end
    }

    public inline function resetBlend() {
        #if (openfl >= "8.4.0")
        this.blendMode = null;
        #end
    }
}