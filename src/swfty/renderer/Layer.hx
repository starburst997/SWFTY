
package swfty.renderer;

#if openfl
typedef DisplayTile = openfl.swfty.renderer.Layer.DisplayTile;
typedef EngineLayer = openfl.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = openfl.swfty.renderer.Layer.FinalLayer;

#elseif heaps
typedef DisplayTile = heaps.swfty.renderer.Layer.DisplayTile;
typedef EngineLayer = heaps.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = heaps.swfty.renderer.Layer.FinalLayer;

#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end

@:forward(x, y, scaleX, scaleY, rotation, alpha, loadBytes, reload, getAllNames)
abstract Layer(FinalLayer) from FinalLayer to FinalLayer {
    public static inline function load(path:String, ?onComplete:Layer->Void, ?onError:Dynamic->Void, ?width:Int, ?height:Int) {
        var layer = Layer.create();
        File.loadBytes(path, bytes -> {
            layer.loadBytes(bytes, () -> {
                if (onComplete != null) onComplete(layer);
            }, onError);
        }, onError);
        return layer;
    }
    
    public static inline function create(?width:Int, ?height:Int):Layer {
        return FinalLayer.create(width, height);
    }

    public inline function add(sprite:Sprite) {
        this.addSprite(sprite);
    }

    public inline function remove(sprite:Sprite) {
        this.removeSprite(sprite);
    }

    public inline function get(linkage:String):Sprite {
        return this.get(linkage);
    }
}