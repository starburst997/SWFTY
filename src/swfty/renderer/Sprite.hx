package swfty.renderer;

#if openfl
typedef EngineSprite = openfl.swfty.renderer.Sprite;

@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove)
abstract Sprite(EngineSprite) from EngineSprite to EngineSprite {
    public var parent(get, never):Sprite;
    public inline function get_parent():Sprite {
        return this.getParent();
    }
    
    public inline function get(name:String):Sprite {
        return this.get(name);
    }

    public inline function getText(name:String):Text {
        return this.getText(name);
    }
}
#elseif heaps
typedef EngineSprite = heaps.swfty.renderer.Sprite;

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract Sprite(EngineSprite) from EngineSprite to EngineSprite {
    public var parent(get, never):Sprite;
    public inline function get_parent():Sprite {
        return this.getParent();
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
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end