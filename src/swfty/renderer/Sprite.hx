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

#elseif heaps
typedef EngineSprite = h2d.Object;
typedef EngineBitmap = heaps.swfty.renderer.Sprite.FinalSprite;
typedef DisplaySprite = heaps.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = heaps.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = heaps.swfty.renderer.Sprite.FinalSprite;

#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end

@:forward(x, y, scaleX, scaleY, rotation, alpha, visible, addRender, removeRender)
abstract Sprite(FinalSprite) from FinalSprite to FinalSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String):Sprite {
        return new FinalSprite(layer, definition, linkage);
    }

    public var parent(get, never):Sprite;
    public inline function get_parent():Sprite {
        return this.getParent();
    }

    public inline function top():Sprite {
        this.top();
        return this;
    }

    public inline function bottom():Sprite {
        this.bottom();
        return this;
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