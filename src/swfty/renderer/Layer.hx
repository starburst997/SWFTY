
package swfty.renderer;

import haxe.io.Bytes;

#if (macro || void)
typedef DisplayTile = void.swfty.renderer.Layer.DisplayTile;
typedef EngineContainer = void.swfty.renderer.Layer.EngineContainer;
typedef EngineLayer = void.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = void.swfty.renderer.Layer.FinalLayer;

#elseif (openfl && list)
typedef DisplayTile = openfl_list.swfty.renderer.Layer.DisplayTile;
typedef EngineContainer = openfl_list.swfty.renderer.Layer.EngineContainer;
typedef EngineLayer = openfl_list.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = openfl_list.swfty.renderer.Layer.FinalLayer;

#elseif openfl
typedef DisplayTile = openfl.swfty.renderer.Layer.DisplayTile;
typedef EngineContainer = openfl.swfty.renderer.Layer.EngineContainer;
typedef EngineLayer = openfl.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = openfl.swfty.renderer.Layer.FinalLayer;

#elseif heaps
typedef DisplayTile = heaps.swfty.renderer.Layer.DisplayTile;
typedef EngineContainer = heaps.swfty.renderer.Layer.EngineContainer;
typedef EngineLayer = heaps.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = heaps.swfty.renderer.Layer.FinalLayer;

#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end

@:forward(id, getIndex, offset, calculateRenderID, renderID, spriteRenderID, parentLayer, addLayer, addLayerAt, removeLayer, container, empty, sleeping, loaded, textureMemory, screenWidth, screenHeight, scale, x, y, scaleX, scaleY, rotation, alpha, visible, dispose, pause, canInteract, path, removeAll, addPostRenderNow, addPostRender, removePostRender, addRender, addRenderNow, removeRender, removeWake, removeSleep, addWake, addSleep, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouse, base, baseLayout, loadBytes, loadImage, reload, update, getAllNames, time, hasParent, disposed, shared, tileset)
abstract Layer(BaseLayer) from BaseLayer to BaseLayer {
    public static inline function load(?width:Int, ?height:Int, ?path:String, ?bytes:Bytes, ?onComplete:Layer->Void, ?onError:Dynamic->Void):Layer {
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

    var _base(get, never):BaseLayer;
    inline function get__base():BaseLayer {
        return this;
    }

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

    public var mask(get, set):Rectangle;
    inline function get_mask():Rectangle {
        @:privateAccess return this._mask;
    }

    inline function set_mask(mask:Rectangle):Rectangle {
        @:privateAccess return this._mask = mask;
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

    public inline function addAt(sprite:Sprite, index = 0) {
        this.addSpriteAt(sprite, 0);
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

    public inline function hasDefinition(linkage:String):Bool {
        return this.hasMC(linkage);
    }
}