package swfty.renderer;

#if openfl
typedef EngineSprite = openfl.swfty.renderer.Sprite;

@:forward(x, y, scaleX, scaleY, rotation, add, remove)
abstract Sprite(EngineSprite) from EngineSprite to EngineSprite {
    
}
#elseif heaps
typedef EngineSprite = heaps.swfty.renderer.Sprite;

@:forward(x, y, scaleX, scaleY, rotation)
abstract Sprite(EngineSprite) from EngineSprite to EngineSprite {
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