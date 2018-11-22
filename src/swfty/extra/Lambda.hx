package swfty.extra;

using swfty.extra.Lambda;

// Extra Functional Programming shorthand
class LambdaSprite {

    public static inline function show(sprite:Sprite, ?name:String, visible = true) {
        var child = name == null ? sprite : sprite.get(name);
        child.visible = visible;
        return sprite;
    }

    public static inline function hide(sprite:Sprite, ?name:String, visible = false) {
        var child = name == null ? sprite : sprite.get(name);
        child.visible = visible;
        return sprite;
    }

    public static inline function removeFromParent(sprite:Sprite, ?name:String) {
        var child = name == null ? sprite : sprite.get(name);
        if (child.parent != null) child.parent.remove(child);
        return sprite;
    }

    public static inline function setAlpha(sprite:Sprite, ?name:String, alpha:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.alpha = alpha;
        return sprite;
    }

    public static inline function setScale(sprite:Sprite, ?name:String, scale:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.scaleX = child.scaleY = scale;
        return sprite;
    }

    public static inline function setScaleX(sprite:Sprite, ?name:String, scale:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.scaleX = scale;
        return sprite;
    }

    public static inline function setScaleY(sprite:Sprite, ?name:String, scale:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.scaleY = scale;
        return sprite;
    }

    public static inline function setX(sprite:Sprite, ?name:String, x:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.x = x;
        return sprite;
    }

    public static inline function setY(sprite:Sprite, ?name:String, y:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.y = y;
        return sprite;
    }

    public static inline function setPosition(sprite:Sprite, ?name:String, x:Float, y:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.x = x;
        child.y = y;
        return sprite;
    }

    public static inline function shortText(sprite:Sprite, name:String, text:String) {
        sprite.getText(name).shortText(text);
        return sprite;
    }
}

class LambdaText {

    public static inline function shortText(label:Text, text:String) {
        label.short = true;
        label.text = text;
        
        return label;
    }
}