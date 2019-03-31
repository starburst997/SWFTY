package openfl_list.swfty.renderer;

import openfl.geom.Matrix;

typedef EngineSprite = openfl.display.Sprite;
typedef EngineBitmap = openfl.display.Bitmap;

@:keepSub // Fix DCE=full
class FinalSprite extends BaseSprite {

    static var pt = new openfl.geom.Point();

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

    public override function localToLayer(x:Float = 0.0, y:Float = 0.0):Point {
        pt.x = x;
        pt.y = y;
        pt = this.localToGlobal(pt);

        return { x: pt.x, y: pt.y };
    }

    public override function layerToLocal(x:Float, y:Float):Point {
        pt.x = x;
        pt.y = y;
        pt = this.globalToLocal(pt);

        return { x: pt.x, y: pt.y };
    }

    public override function calcBounds(?relative:BaseSprite, ?global = false):Rectangle {
        return if (global) {
            if (forceBounds != null) {
                var pt = localToLayer(forceBounds.x, forceBounds.y);
                var pt2 = localToLayer(forceBounds.x + forceBounds.width, forceBounds.y + forceBounds.height);

                {
                    x: pt.x,
                    y: pt.y,
                    width: pt2.x - pt.x,
                    height: pt2.y - pt.y
                }
            } else {
                var rect = this.getBounds(layer);

                #if dev
                if (rect.width <= 0 || rect.height <= 0) trace('Calc bounds bad values!!!!! $_name');
                #end

                {
                    x: rect.x,
                    y: rect.y,
                    width: rect.width,
                    height: rect.height
                }
            }

        } else {
            if (relative == null) relative = this;
            
            if (forceBounds != null) {
                var pt = localToLayer(forceBounds.x, forceBounds.y);
                var pt2 = localToLayer(forceBounds.x + forceBounds.width, forceBounds.y + forceBounds.height);
                
                pt = relative.layerToLocal(pt.x, pt.y);
                pt2 = relative.layerToLocal(pt2.x, pt2.y);
                
                {
                    x: pt.x,
                    y: pt.y,
                    width: pt2.x - pt.x,
                    height: pt2.y - pt.y
                }
            } else {
                var rect = this.getBounds(relative);

                #if dev
                if (rect.width <= 0 || rect.height <= 0) trace('Calc bounds bad values!!!!! $_name');
                #end

                {
                    x: rect.x,
                    y: rect.y,
                    width: rect.width,
                    height: rect.height
                }
            }
        }
    }

    public override function top() {
        if (this.parent != null) parent.setChildIndex(this, parent.numChildren - 1);
    }

    public override function bottom() {
        if (this.parent != null) parent.setChildIndex(this, 0);
    }

    public override function addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        super.addSpriteAt(sprite, index);

        // TODO: This shouldn't be necessary!
        /*#if !dev
        if (index >= 0 && index <= numChildren)
        #end*/

        addChildAt(sprite, index);
        sprite._parent = this;
    }

    public override function addSprite(sprite:FinalSprite) {
        super.addSprite(sprite);
        addChild(sprite);
        sprite._parent = this;
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

    public override function setIndex(sprite:FinalSprite, index:Int) {
        super.setIndex(sprite, index);
        setChildIndex(sprite, index);
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
        this.transform.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha);
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
        this.transform.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha, rAdd, gAdd, bAdd, 0.0);
    }

    public inline function resetColor() {
        this.transform.colorTransform = new openfl.geom.ColorTransform(1.0, 1.0, 1.0, this.alpha, 0.0, 0.0, 0.0, 0.0);
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