package swfty.extra;

// Extra Functional Programming shorthand
class Lambda {

    public static inline function show(sprite:Sprite) {
        sprite.visible = true;
        return sprite;
    }

    public static inline function hide(sprite:Sprite) {
        sprite.visible = false;
        return sprite;
    }

    public static inline function setAlpha(sprite:Sprite, alpha:Float) {
        sprite.alpha = alpha;
        return sprite;
    }

    public static inline function setScale(sprite:Sprite, scale:Float) {
        sprite.scaleX = sprite.scaleY = scale;
        return sprite;
    }

    public static inline function setScaleX(sprite:Sprite, scale:Float) {
        sprite.scaleX = scale;
        return sprite;
    }

    public static inline function setScaleY(sprite:Sprite, scale:Float) {
        sprite.scaleY = scale;
        return sprite;
    }
}