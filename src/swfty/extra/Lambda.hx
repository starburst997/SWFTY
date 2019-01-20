package swfty.extra;

using swfty.extra.Lambda;
using swfty.utils.MathUtils;

// Extra Functional Programming shorthand
class LambdaSprite {

    public static function iter(sprite:Sprite, ?name:String, f:Sprite->Void) {
        var i = 0;
        // Grab either name0 or name1 first, then continue by incrementing until there is none
        var child:Sprite = sprite.exists('$name$i') ? sprite.get('$name$i') : (sprite.exists('$name${++i}') ? sprite.get('$name$i') : null);
        while (child != null) {
            f(child);
            child = sprite.exists('$name${++i}') ? sprite.get('$name$i') : null;
        }
    }

    public static function iteri(sprite:Sprite, ?name:String, f:Sprite->Int->Void) {
        var i = 0;
        // Grab either name0 or name1 first, then continue by incrementing until there is none
        var child:Sprite = sprite.exists('$name$i') ? sprite.get('$name$i') : (sprite.exists('$name${++i}') ? sprite.get('$name$i') : null);
        while (child != null) {
            f(child, i);
            child = sprite.exists('$name${++i}') ? sprite.get('$name$i') : null;
        }
    }

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

    public static inline function render(sprite:Sprite, ?name:String, f:Float->Void) {
        var child = name == null ? sprite : sprite.get(name);
        child.addRender(f);
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

    public static inline function fit(sprite:Sprite, ?width:Float, ?height:Float) {
        var bounds = sprite.calcBounds(sprite.parent);

        if (width == null) width = sprite.layer.width;
        if (height == null) height = sprite.layer.height;

        // Try to fit
        var scale = if (bounds.width < bounds.height) {
            var scale = height / bounds.height;
            if ((bounds.width * scale).greater(width)) {
                scale = width / bounds.width;
            } else {
                scale;
            }
        } else {
            var scale = width / bounds.width;
            if ((bounds.height * scale).greater(height)) {
                scale = height / bounds.height;
            } else {
                scale;
            }
        }

        sprite.setScale(scale);
        sprite.setPosition(-bounds.x * scale - (bounds.width * scale - width) / 2, -bounds.y * scale - (bounds.height * scale - height) / 2);

        return sprite;
    }
}

class LambdaText {

    public static inline function shortText(label:Text, text:String) {
        label.short = true;
        label.text = text;
        
        return label;
    }

    public static inline function fitSizeText(label:Text, text:String) {
        label.fit = true;
        label.fitVertically = false;
        label.text = text;
        
        return label;
    }

    public static inline function fitText(label:Text, text:String) {
        label.fit = true;
        label.text = text;
        
        return label;
    }
}