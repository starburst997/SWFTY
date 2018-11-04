
package swfty.renderer;

#if openfl
typedef EngineLayer = openfl.swfty.renderer.Layer;

@:forward(x, y, scaleX, scaleY, rotation, get, load, getAllNames, add, remove)
abstract Layer(EngineLayer) from EngineLayer to EngineLayer {
    public static inline function create(?width:Int, ?height:Int) {
        return EngineLayer.create(width == null ? 256 : width, height == null ? 256 : height);
    }
}
#elseif heaps
typedef EngineLayer = heaps.swfty.renderer.Layer;

@:forward(x, y, scaleX, scaleY, rotation, get, load, getAllNames)
abstract Layer(EngineLayer) from EngineLayer to EngineLayer {
    public static inline function create(?width:Int, ?height:Int) {
        return EngineLayer.create();
    }

    public inline function add(sprite:Sprite) {
        this.addSprite(sprite);
    }

    public inline function remove(sprite:Sprite) {
        this.removeSprite(sprite);
    }
}
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end