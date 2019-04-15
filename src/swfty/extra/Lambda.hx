package swfty.extra;

using swfty.extra.Lambda;
using swfty.utils.MathUtils;

// Extra Functional Programming shorthand
class LambdaSprite {

    static inline var FOLLOW_ID = 'follow';

    public static inline function empty(sprite:Sprite) {
        for (child in sprite.sprites) {
            child.removeFromParent();
        }

        return sprite;
    }

    public static function iter(sprite:Sprite, ?name:String, f:Sprite->Void) {
        var i = 0;
        // Grab either name0 or name1 first, then continue by incrementing until there is none
        var child:Sprite = sprite.exists('$name$i') ? sprite.get('$name$i') : (sprite.exists('$name${++i}') ? sprite.get('$name$i') : null);
        while (child != null) {
            f(child);
            child = sprite.exists('$name${++i}') ? sprite.get('$name$i') : null;
        }

        return sprite;
    }

    public static function iteri(sprite:Sprite, ?name:String, f:Sprite->Int->Void) {
        var i = 0;
        // Grab either name0 or name1 first, then continue by incrementing until there is none
        var child:Sprite = sprite.exists('$name$i') ? sprite.get('$name$i') : (sprite.exists('$name${++i}') ? sprite.get('$name$i') : null);
        while (child != null) {
            f(child, i);
            child = sprite.exists('$name${++i}') ? sprite.get('$name$i') : null;
        }

        return sprite;
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

    public static inline function renderOnce(sprite:Sprite, ?name:String, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        function once(dt) {
            f();
            child.removeRender(once);
        }
        child.addRender(once);
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

    public static inline function setScaleXY(sprite:Sprite, ?name:String, scaleX:Float, scaleY:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.scaleX = scaleX;
        child.scaleY = scaleY;
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

    public static inline function setRotation(sprite:Sprite, ?name:String, radian:Float) {
        var child = name == null ? sprite : sprite.get(name);
        child.rotation = radian;
        return sprite;
    }

    public static inline function shortText(sprite:Sprite, name:String, text:String) {
        sprite.getText(name).shortText(text);
        return sprite;
    }

    public static inline function getLayerBounds(sprite:Sprite) {
        return sprite.calcBounds(true);
    }

    // Fit as tight as possible, we see everything
    public static inline function fit(sprite:Sprite, ?width:Float, ?height:Float, ?useScreen = true) {
        var bounds = sprite.calcBounds(sprite.parent);

        if (width == null) width = useScreen ? sprite.layer.screenWidth : sprite.layer.width;
        if (height == null) height = useScreen ? sprite.layer.screenHeight : sprite.layer.height;

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

    // Mainly for background, makes sure the whole area is covered
    public static inline function cover(sprite:Sprite, ?padding = 0, ?width:Float, ?height:Float, ?useScreen = true) {
        var bounds = sprite.calcBounds(sprite.parent);

        if (width == null) width = useScreen ? sprite.layer.screenWidth : sprite.layer.width;
        if (height == null) height = useScreen ? sprite.layer.screenHeight : sprite.layer.height;

        // Try to fit
        var scale = if (bounds.width < bounds.height) {
            var scale = width / (bounds.width - padding * 2);
            if (((bounds.height - padding * 2) * scale).lower(height)) {
                scale = height / (bounds.height - padding * 2);
            } else {
                scale;
            }
        } else {
            var scale = height / (bounds.height - padding * 2);
            if (((bounds.width - padding * 2) * scale).lower(width)) {
                scale = width / (bounds.width - padding * 2);
            } else {
                scale;
            }
        }

        sprite.setScale(scale);
        sprite.setPosition(-bounds.x * scale - (bounds.width * scale - width) / 2, -bounds.y * scale - (bounds.height * scale - height) / 2);

        return sprite;
    }

    // TODO: Need some sort of priority to makes sure we grab the position of "object" after it updates
    // TODO: If object is destroyed / disposed whatever, we should "unfollow"
    public static inline function follow(sprite:Sprite, object:Sprite, ?x = 0.0, ?y = 0.0) {
        sprite.addRender(FOLLOW_ID, function(dt) {
            var global = object.localToLayer();//(object.x, object.y);
            var local = sprite.layerToLocal(global.x, global.y);
            
            sprite.x = local.x + x;
            sprite.y = local.y + y;
        });

        return sprite;
    }

    public static inline function unfollow(sprite:Sprite) {
        sprite.removeRender(FOLLOW_ID);

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