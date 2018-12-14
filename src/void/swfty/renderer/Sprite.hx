package void.swfty.renderer;

class EngineSprite {

    public var visible:Bool = true;
    public var x:Float = 0.0;
    public var y:Float = 0.0;
    public var scaleX:Float = 1.0;
    public var scaleY:Float = 1.0;
    public var rotation:Float = 0.0;
    public var alpha:Float = 1.0;

    public function new() {

    }
}

class EngineBitmap {

    public var x:Float = 0.0;
    public var y:Float = 0.0;
    public var scaleX:Float = 1.0;
    public var scaleY:Float = 1.0;
    
    public function new(tile:DisplayTile) {

    }
}

class FinalSprite extends BaseSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        super(layer, definition, linkage);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        
    }

    public inline function color(r:Int, g:Int, b:Int) {
        
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        
    }

    public inline function resetColor() {
        
    }

    public inline function blend(mode:BlendMode) {
        
    }

    public inline function resetBlend() {
        
    }
}