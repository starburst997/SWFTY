package swfty.utils;

class MathUtils {
    
    public static inline function x(tx:Float) {
        return tx;
    }

    public static inline function y(ty:Float) {
        return ty;
    }

    public static inline function scaleX(a:Float, b:Float, c:Float, d:Float) {
        return if (b == 0)
            a;
        else
            // TODO: Figure out why I had to do that
            Math.sqrt(a * a + b * b) * (a < 0 ? -1 : 1) * (d < 0 ? -1 : 1);
    }

    public static inline function scaleY(a:Float, b:Float, c:Float, d:Float) {
        return if (c == 0)
            d;
        else
            // TODO: Why is this working?
            Math.sqrt(c * c + d * d);// * (b < 0 ? -1 : 1) * (c < 0 ? -1 : 1);
    }

    public static inline function rotation(b:Float, c:Float, d:Float) {
        return if (b == 0 && c == 0)
            0.0;
        else {
            var radians = Math.atan2(d, c) - (Math.PI / 2);
            radians;
        }
    }
}