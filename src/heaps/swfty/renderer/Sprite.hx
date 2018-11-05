package heaps.swfty.renderer;

import swfty.renderer.BaseSprite;

typedef EngineSprite = h2d.Object;
typedef EngineBitmap = FinalSprite;

class FinalSprite extends BaseSprite {

    public var tile:h2d.Tile;
    public var color:h3d.Vector;

    var _lastAlpha = 1.0;
    var renders:Array<Float->Void>;

    public static inline function create(layer:BaseLayer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, tile, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String) {
        this.tile = tile;
        
        renders = [];
        color = new h3d.Vector(1, 1, 1, 1);
        
        super(layer, definition, linkage);
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

    public function update(dt:Float) {
        // Hack for alpha change
        if (_lastAlpha != alpha) posChanged = true;
        _lastAlpha = alpha;

        for (sprite in _sprites) {
            sprite.update(dt);
        }

        for (f in renders) f(dt);
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

    public function addRender(f:Float->Void) {
        renders.push(f);
    }

    public function removeRender(f:Float->Void) {
        renders.remove(f);
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
        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(b, c, d);
    }

    public inline function color(r:Int, g:Int, b:Int) {
        this.r = r/255;
        this.g = g/255;
        this.b = b/255;
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
        this.r = r/255;
        this.g = g/255;
        this.b = b/255;
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