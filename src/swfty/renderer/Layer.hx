
package swfty.renderer;

import haxe.io.Bytes;

#if (macro || void)
typedef DisplayTile = void.swfty.renderer.Layer.DisplayTile;
typedef EngineLayer = void.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = void.swfty.renderer.Layer.FinalLayer;

#elseif openfl
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

@:forward(x, y, scaleX, scaleY, rotation, alpha, dispose, pause, removeAll, addRender, removeRender, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouse, base, baseLayout, loadBytes, reload, update, getAllNames)
abstract Layer(BaseLayer) from BaseLayer to BaseLayer {
    public static inline function load(?path:String, ?bytes:Bytes, ?width:Int, ?height:Int, ?onComplete:Layer->Void, ?onError:Dynamic->Void):Layer {
        var layer = FinalLayer.create(width, height);
        
        if (path != null) {
            File.loadBytes(path, function(bytes) {
                layer.loadBytes(bytes, function() {
                    if (onComplete != null) onComplete(layer);
                }, onError);
            }, onError);
        }

        if (bytes != null) {
            layer.loadBytes(bytes, function() {
                if (onComplete != null) onComplete(layer);
            }, onError);
        }
        
        return layer;
    }

    public static inline function empty(?width:Int, ?height:Int):Layer {
        return FinalLayer.create(width, height);
    }

    public var mouseX(get, never):Float;
    public var mouseY(get, never):Float;

    inline function get_mouseX() {
        return this.getMouseX();
    }
    inline function get_mouseY() {
        return this.getMouseY();
    }

    public var width(get, never):Float;
    public var height(get, never):Float;

    inline function get_width() {
        @:privateAccess return this._width;
    }
    inline function get_height() {
        @:privateAccess return this._height;
    }

    public function layout(targetWidth:Float, targetHeight:Float) {
        // First layout by height, if offset is negative, then we layout by width
        // Ideally you make your UI to fit vertically, if the device is larger in width it will simply offset
        var scale = height / targetHeight;
        this.baseLayout.scaleX = this.baseLayout.scaleY = scale;
        this.baseLayout.x = (width - (targetWidth * scale)) / 2.0;

        // But if the screen is narrower than you anticipated (like iPhone X), it is best to then offset vertically
        if (this.baseLayout.x < 0) {
            this.baseLayout.x = 0;

            var scale = width / targetWidth;
            this.baseLayout.scaleX = this.baseLayout.scaleY = scale;
            this.baseLayout.y = (height - (targetHeight * scale)) / 2.0;
        }

        return this;
    }

    public inline function add(sprite:Sprite) {
        this.addSprite(sprite);
        return this;
    }

    public inline function remove(sprite:Sprite) {
        this.removeSprite(sprite);
        return this;
    }

    public inline function create(linkage:String):Sprite {
        return this.get(linkage);
    }
}