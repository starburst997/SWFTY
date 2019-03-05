package swfty.renderer;

// EngineSprite  = The class used in the underlying engine to display a container of objects, (ex: TileContainer in openfl)
// EngineBitmap  = The class used in the underlying engine to display a single image, (ex: Tile in openfl)
// DisplaySprite = An abstract over EngineSprite that allows a shared interfaces to easily share code betweem different engines
// DisplayBitmap = Same as above but for EngineBitmap
// FinalSprite   = An engine specific Sprite that extends BaseSprite (which extends EngineSprite)
// Sprite        = An abstract over FinalSprite that can be used over any engine

#if (macro || void)
typedef EngineSprite = void.swfty.renderer.Sprite.EngineSprite;
typedef EngineBitmap = void.swfty.renderer.Sprite.EngineBitmap;
typedef DisplaySprite = void.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = void.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = void.swfty.renderer.Sprite.FinalSprite;

#elseif (openfl && list)
typedef EngineSprite = openfl_list.swfty.renderer.Sprite.EngineSprite;
typedef EngineBitmap = openfl_list.swfty.renderer.Sprite.EngineBitmap;
typedef DisplaySprite = openfl_list.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = openfl_list.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = openfl_list.swfty.renderer.Sprite.FinalSprite;

#elseif openfl
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

@:forward(x, y, scaleX, scaleY, rotation, alpha, visible, interactive, loaded, width, height, exists, calcBounds, bounds, addRender, removeRender, setBounds, setIndex, debug, addBitmap, localToLayer, layerToLocal, colorize)
abstract Sprite(FinalSprite) from FinalSprite to FinalSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String):Sprite {
        return new FinalSprite(layer, definition, linkage);
    }

    public function getIndex(?sprite:Sprite):Int {
        return if (sprite == null) {
            parent == null ? -1 : parent.getIndex(this);
        } else {
            this.getIndex(sprite);
        }
    }

    public var sprites(get, never):Array<Sprite>;
    inline function get_sprites():Array<Sprite> {
        @:privateAccess return this._sprites;
    }

    public var name(get, set):String;
    inline function get_name():String {
        @:privateAccess return this._name;
    }

    inline function set_name(name:String):String {
        @:privateAccess return this._name = name;
    }

    #if openfl
    public var rotation(get, set):Float;
    inline function get_rotation():Float {
        return this.rotation / 180 * Math.PI;
    }

    inline function set_rotation(value:Float):Float {
        return this.rotation = value / Math.PI * 180;
    }
    #end

    public var parent(get, never):Sprite;
    public inline function get_parent():Sprite {
        return this.getParent();
    }

    public var layer(get, never):Layer;
    public inline function get_layer():Layer {
        return this.layer;
    }

    public inline function clone():Sprite {
        @:privateAccess return create(this.layer, this._definition, this._linkage);
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

    public inline function addAt(sprite:Sprite, index:Int = 0) {
        // TODO: Is this check necessary?
        var total = sprites.length;
        this.addSpriteAt(sprite, index < 0 ? 0 : index > total ? total : index);
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