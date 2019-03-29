package void.swfty.renderer;

import haxe.io.Bytes;

class EngineContainer {

    public function new() {
        
    }
}

class EngineLayer {

    public function new() {
        
    }
}

typedef DisplayTile = Int;

@:access(swfty.renderer.BaseSprite)
class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        super();

        _width = width;
        _height = height;
    }

    override function get_base() {
        if (base == null) {
            base = FinalSprite.create(this);
            base._name = 'base';
            base.countVisible = false;
        }
        return base;
    }

    public override function addSprite(sprite:Sprite) {
        super.addSprite(sprite);
    }

    public override function removeSprite(sprite:Sprite) {
        super.removeSprite(sprite);
    }

    public override function emptyTile(?id:Int):DisplayTile {
        return -1;
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        if (onComplete != null) onComplete();
    }
}