class MathTools {
    public static inline function int(f:Float):Int {
        return Std.int(f);
    }

    public static inline function parseInt(str:String):Int {
        return Std.parseInt(str);
    }

    public static inline function parseFloat(str:String):Float {
        return Std.parseFloat(str);
    }

    public static inline function safeFloat(str:String):Float {
        return Std.parseFloat(~/[^0-9\.]*/g.replace(str, ''));
    }

    public static inline function toString(value:Float, p:Int = 5){
        var t = Std.int(Math.pow(10, p));
        return Std.string(Std.int(value * t) / t);
    }

    public static inline function clamp(val:Int, low:Int, high:Int) {
        return if (val < low) low;
        else if (val > high) high;
        else val;
    }
}

class HeapsSprite {

    @:generic
    public static inline function setPosition<T:h2d.Sprite>(sprite:T, ?x:Float, ?y:Float):T {
        sprite.setPosition(x == null ? sprite.x : x, y == null ? sprite.y : y);
        return sprite;
    }

    @:generic
    public static inline function setX<T:h2d.Sprite>(sprite:T, x:Float):T {
        sprite.setPosition(x, sprite.y);
        return sprite;
    }

    @:generic
    public static inline function setY<T:h2d.Sprite>(sprite:T, y:Float):T {
        sprite.setPosition(sprite.x, y);
        return sprite;
    }

    @:generic
    public static inline function changeAlpha<T:h2d.Sprite>(sprite:T, alpha:Float) {
        sprite.alpha = alpha;
        return sprite;
    }

    @:generic
    public static inline function changeScale<T:h2d.Sprite>(sprite:T, scale:Float) {
        sprite.setScale(scale);
        return sprite;
    }

    @:generic
    public static inline function changeRotation<T:h2d.Sprite>(sprite:T, rotation:Float) {
        sprite.rotation = rotation;
        return sprite;
    }
}

class HeapsText {

    public static inline function text(font:h2d.Font, ?parent:h2d.Sprite):h2d.Text {
        return new h2d.Text(font, parent);
    }

    public static inline function setAlpha(text:h2d.Text, alpha:Float):h2d.Text {
        text.alpha = alpha;
        return text;
    }

    public static inline function setColor(text:h2d.Text, color:Int):h2d.Text {
        text.textColor = color;
        return text;
    }

    public static inline function setText(text:h2d.Text, str:String):h2d.Text {
        text.text = str;
        return text;
    }

    public static inline function setAlign(text:h2d.Text, align:h2d.Text.Align):h2d.Text {
        text.textAlign = align;
        return text;
    }

    public static inline function setSpacing(text:h2d.Text, spacing:Float):h2d.Text {
        text.letterSpacing = spacing.int();
        return text;
    }

    public static inline function setMax(text:h2d.Text, max:Float):h2d.Text {
        text.maxWidth = max;
        return text;
    }
}