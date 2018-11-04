
package swfty.renderer;

#if openfl
typedef EngineLayer = openfl.swfty.renderer.Layer;

@:forward(x, y, scaleX, scaleY, rotation, alpha, load, reload, getAllNames, add, remove)
abstract Layer(EngineLayer) from EngineLayer to EngineLayer {
    public static inline function create(?width:Int, ?height:Int):Layer {
        return EngineLayer.create(width == null ? 256 : width, height == null ? 256 : height);
    }

    public inline function get(linkage:String):Sprite {
        return this.get(linkage);
    }
}
#elseif heaps
typedef EngineLayer = heaps.swfty.renderer.Layer;

@:forward(x, y, scaleX, scaleY, rotation, alpha, load, reload, getAllNames)
abstract Layer(EngineLayer) from EngineLayer to EngineLayer {
    public static inline function create(?width:Int, ?height:Int):Layer {
        return EngineLayer.create();
    }

    public inline function get(linkage:String):Sprite {
        return this.get(linkage);
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