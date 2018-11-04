package swfty.renderer;

// EngineSprite  = The class used in the underlying engine to display a container of objects, (ex: TileContainer in openfl)
// EngineBitmap  = The class used in the underlying engine to display a single image, (ex: Tile in openfl)
// DisplaySprite = An abstract over EngineSprite that allows a shared interfaces to easily share code betweem different engines
// DisplayBitmap = Same as above but for EngineBitmap
// FinalSprite   = An engine specific Sprite that extends BaseSprite (which extends EngineSprite)
// Sprite        = An abstract over FinalSprite that can be used over any engine

#if openfl
typedef EngineSprite = openfl.swfty.renderer.Sprite.EngineSprite;
typedef EngineBitmap = openfl.swfty.renderer.Sprite.EngineBitmap;
typedef DisplaySprite = openfl.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = openfl.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = openfl.swfty.renderer.Sprite.FinalSprite;
typedef Sprite = openfl.swfty.renderer.Sprite;

#elseif heaps
typedef EngineTile = heaps.swfty.renderer.Sprite;
typedef EngineSprite = heaps.swfty.renderer.Sprite;
typedef DisplaySprite = h2d.Object;

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayTile(EngineTile) from EngineTile to EngineTile {

    public static inline function create(layer:EngineLayer, id:Int, og:Bool = false):DisplayTile {
        var tile = layer.getTile(id);
        var sprite = EngineTile.create(layer, tile);
        sprite.og = true;

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
abstract SharedDisplaySprite(DisplaySprite) from DisplaySprite to DisplaySprite {

    public inline function removeChildren() {
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
        this.r = r;
        this.g = g;
        this.b = b;
    }

    public inline function resetColor() {
        this.r = 1.0;
        this.g = 1.0;
        this.b = 1.0;
    }

    public inline function blend(mode:BlendMode) {
        Log.warn('Blend Mode not implemented');
    }

    public inline function resetBlend() {
        Log.warn('Blend Mode not implemented');
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, visible)
abstract Sprite(EngineSprite) from EngineSprite to EngineSprite {

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
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end