package heaps.swfty.renderer;

import swfty.renderer.BaseSprite;

typedef EngineSprite = h2d.Object;
typedef EngineBitmap = FinalSprite;

class FinalSprite extends BaseSprite {

    public var tile:h2d.Tile;
    public var color:h3d.Vector;

    var _lastAlpha = 1.0;
    
    public static inline function create(layer:BaseLayer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, tile, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String) {
        this.tile = tile;
        
        color = new h3d.Vector(1, 1, 1, 1);
        
        super(layer, definition, linkage);
    }

    override function set__name(name:String) {
        if (_parent != null) {
            @:privateAccess _parent._names.set(name, this);
        }
        
        return super.set__name(name);
    }

    override function getBoundsRec( relativeTo : h2d.Object, out : h2d.col.Bounds, forSize : Bool ) {
		super.getBoundsRec(relativeTo, out, forSize);
		if( tile != null ) addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
	}

    override function calcBounds(?relative:BaseSprite):Rectangle {
        var bounds = getBounds(relative);
        return {
            x: bounds.x,
            y: bounds.y,
            width: bounds.width,
            height: bounds.height
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

    public override function update(dt:Float) {
        // Hack for alpha change only
        if (_lastAlpha != alpha) posChanged = true;
        _lastAlpha = alpha;
        
        super.update(dt);
    }

    public function render(ctx) {
        drawRec(ctx);
    }

    override function draw(ctx) {
        if (tile != null) {    
            @:privateAccess layer.content.addTransform(
                Std.int(MathUtils.x(absX)), 
                Std.int(MathUtils.y(absY)), 
                MathUtils.scaleX(matA, matB, matC, matD), 
                MathUtils.scaleY(matA, matB, matC, matD), 
                MathUtils.rotation(matB, matC, matD), color, tile);
        }
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
        sprite.remove();
    }

    public override function addBitmap(bitmap:EngineBitmap) {
        bitmap._parent = this;
        addChild(bitmap);
    }

    public override function removeBitmap(bitmap:EngineBitmap) {
        bitmap._parent = null;
        bitmap.remove();
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        var sprite = FinalSprite.create(layer, layer.getTile(id));
        sprite.og = og;
        return sprite;
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        // TODO: This is a bit of extra steps, maybe I should submit a PR to expose the matrix more easily?
        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(b, c, d);
    }

    public inline function color(r:Int, g:Int, b:Int) {
        this.r = r / 255.0;
        this.g = g / 255.0;
        this.b = b / 255.0;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        this.removeChildren();
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(b, c, d);
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        this.r = r / 255.0;
        this.g = g / 255.0;
        this.b = b / 255.0;
    }

    public inline function resetColor() {
        this.r = 1.0;
        this.g = 1.0;
        this.b = 1.0;
    }

    public inline function blend(mode:BlendMode) {
        
    }

    public inline function resetBlend() {
        
    }
}