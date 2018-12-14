package void.swfty.renderer;

import haxe.io.Bytes;

class EngineLayer {

    public var width:Int = 0;
    public var height:Int = 0;

    public function new(width, height) {
        this.width = width;
        this.height = height;
    }
}

typedef DisplayTile = Int;

class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        super(width, height);
    }

    override function get_base() {
        if (base == null) {
            base = FinalSprite.create(this);
        }
        return base;
    }

    public override function addSprite(sprite:Sprite) {
        super.addSprite(sprite);
    }

    public override function removeSprite(sprite:Sprite) {
        super.removeSprite(sprite);
    }

    public override function emptyTile():DisplayTile {
        return -1;
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        if (onComplete != null) onComplete();
    }
}