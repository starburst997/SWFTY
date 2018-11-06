package swfty.extra;

import swfty.renderer.Sprite;

using tweenxcore.Tools;

// Very simple tween meant for SWFTY Sprite (optional extra)
// Nothing fancy and hooks on the update loop of the Sprite
// Will die with the sprite or when it finishes running
// Not exactly super mega optimised, but should do the job just fine

class Tween {

    public static inline function tweenScale(sprite:Sprite, scale:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleX, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleX = sprite.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenScaleX(sprite:Sprite, scale:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleX, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleX = val;
        });
        return sprite;
    }

    public static inline function tweenScaleY(sprite:Sprite, scale:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleY, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenX(sprite:Sprite, x:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.x, x, duration, delay, easing, onComplete, function(val) {
            sprite.x = val;
        });
        return sprite;
    }

    public static inline function tweenY(sprite:Sprite, y:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.y, y, duration, delay, easing, onComplete, function(val) {
            sprite.y = val;
        });
        return sprite;
    }

    public static inline function tweenAlpha(sprite:Sprite, alpha:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.alpha, alpha, duration, delay, easing, onComplete, function(val) {
            sprite.alpha = val;
        });
        return sprite;
    }

    public static inline function tweenRotation(sprite:Sprite, angle:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.rotation, angle, duration, delay, easing, onComplete, function(val) {
            sprite.rotation = val;
        });
        return sprite;
    }

    public static inline function tweenPosition(sprite:Sprite, x:Float, y:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        tweenX(sprite, x, duration, delay, easing, onComplete);
        tweenY(sprite, y, duration, delay, easing, onComplete);
        return sprite;
    }

    public static inline function tweenStop(sprite:Sprite) {
        sprite.removeRender('tween');
        return sprite;
    }

    static inline function setup(sprite:Sprite, from:Float, to:Float, duration:Float, delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void, setVal:Float->Void) {
        var ease = getEasing(sprite.scaleX, to, easing);
        var rate = -delay;
        var done = false;
        sprite.addRender('tween', function render(dt) {
            if (rate >= duration) {
                rate = duration;
                done = true;
                sprite.removeRender('tween', render);
            }

            if (rate >= 0.0) setVal(ease(rate / duration));
            rate += dt;

            if (done && onComplete != null) onComplete();
        });
    }

    static inline function getEasing(from:Float, to:Float, ?easing:Easing) {
        return switch(easing) {
            case SineIn: (rate:Float) -> {
                return rate.sineIn().lerp(from, to);
            };
            case SineOut: (rate:Float) -> {
                return rate.sineOut().lerp(from, to);
            };
            case SineInOut: (rate:Float) -> {
                return rate.sineInOut().lerp(from, to);
            };
            case SineOutIn: (rate:Float) -> {
                return rate.sineOutIn().lerp(from, to);
            };
            case QuadIn: (rate:Float) -> {
                return rate.quadIn().lerp(from, to);
            };
            case QuadOut: (rate:Float) -> {
                return rate.quadOut().lerp(from, to);
            };
            case QuadInOut: (rate:Float) -> {
                return rate.quadInOut().lerp(from, to);
            };
            case QuadOutIn: (rate:Float) -> {
                return rate.quadOutIn().lerp(from, to);
            };
            case CubicIn: (rate:Float) -> {
                return rate.cubicIn().lerp(from, to);
            };
            case CubicOut: (rate:Float) -> {
                return rate.cubicOut().lerp(from, to);
            };
            case CubicInOut: (rate:Float) -> {
                return rate.cubicInOut().lerp(from, to);
            };
            case CubicOutIn: (rate:Float) -> {
                return rate.cubicOutIn().lerp(from, to);
            };
            case QuartIn: (rate:Float) -> {
                return rate.quartIn().lerp(from, to);
            };
            case QuartOut: (rate:Float) -> {
                return rate.quartOut().lerp(from, to);
            };
            case QuartInOut: (rate:Float) -> {
                return rate.quartInOut().lerp(from, to);
            };
            case QuartOutIn: (rate:Float) -> {
                return rate.quartOutIn().lerp(from, to);
            };
            case QuintIn: (rate:Float) -> {
                return rate.quintIn().lerp(from, to);
            };
            case QuintOut: (rate:Float) -> {
                return rate.quintOut().lerp(from, to);
            };
            case QuintInOut: (rate:Float) -> {
                return rate.quintInOut().lerp(from, to);
            };
            case QuintOutIn: (rate:Float) -> {
                return rate.quintOutIn().lerp(from, to);
            };
            case ExpoIn: (rate:Float) -> {
                return rate.expoIn().lerp(from, to);
            };
            case ExpoOut: (rate:Float) -> {
                return rate.expoOut().lerp(from, to);
            };
            case ExpoInOut: (rate:Float) -> {
                return rate.expoInOut().lerp(from, to);
            };
            case ExpoOutIn: (rate:Float) -> {
                return rate.expoOutIn().lerp(from, to);
            };
            case CircIn: (rate:Float) -> {
                return rate.circIn().lerp(from, to);
            };
            case CircOut: (rate:Float) -> {
                return rate.circOut().lerp(from, to);
            };
            case CircInOut: (rate:Float) -> {
                return rate.circInOut().lerp(from, to);
            };
            case CircOutIn: (rate:Float) -> {
                return rate.circOutIn().lerp(from, to);
            };
            case BounceIn: (rate:Float) -> {
                return rate.bounceIn().lerp(from, to);
            };
            case BounceOut: (rate:Float) -> {
                return rate.bounceOut().lerp(from, to);
            };
            case BounceInOut: (rate:Float) -> {
                return rate.bounceInOut().lerp(from, to);
            };
            case BounceOutIn: (rate:Float) -> {
                return rate.bounceOutIn().lerp(from, to);
            };
            case BackIn: (rate:Float) -> {
                return rate.backIn().lerp(from, to);
            };
            case BackOut: (rate:Float) -> {
                return rate.backOut().lerp(from, to);
            };
            case BackInOut: (rate:Float) -> {
                return rate.backInOut().lerp(from, to);
            };
            case BackOutIn: (rate:Float) -> {
                return rate.backOutIn().lerp(from, to);
            };
            case ElasticIn: (rate:Float) -> {
                return rate.elasticIn().lerp(from, to);
            };
            case ElasticOut: (rate:Float) -> {
                return rate.elasticOut().lerp(from, to);
            };
            case ElasticInOut: (rate:Float) -> {
                return rate.elasticInOut().lerp(from, to);
            };
            case ElasticOutIn: (rate:Float) -> {
                return rate.elasticOutIn().lerp(from, to);
            };
            case WarpOut: (rate:Float) -> {
                return rate.warpOut().lerp(from, to);
            };
            case WarpIn: (rate:Float) -> {
                return rate.warpIn().lerp(from, to);
            };
            case WarpInOut: (rate:Float) -> {
                return rate.warpInOut().lerp(from, to);
            };
            case WarpOutIn: (rate:Float) -> {
                return rate.warpOutIn().lerp(from, to);
            };
            case Linear, _: (rate:Float) -> {
                return rate.linear().lerp(from, to);
            }
        }
    }
}

enum Easing {
    Linear;
    SineIn;
    SineOut;
    SineInOut;
    SineOutIn;
    QuadIn;
    QuadOut;
    QuadInOut;
    QuadOutIn;
    CubicIn;
    CubicOut;
    CubicInOut;
    CubicOutIn;
    QuartIn;
    QuartOut;
    QuartInOut;
    QuartOutIn;
    QuintIn;
    QuintOut;
    QuintInOut;
    QuintOutIn;
    ExpoIn;
    ExpoOut;
    ExpoInOut;
    ExpoOutIn;
    CircIn;
    CircOut;
    CircInOut;
    CircOutIn;
    BounceIn;
    BounceOut;
    BounceInOut;
    BounceOutIn;
    BackIn;
    BackOut;
    BackInOut;
    BackOutIn;
    ElasticIn;
    ElasticOut;
    ElasticInOut;
    ElasticOutIn;
    WarpOut;
    WarpIn;
    WarpInOut;
    WarpOutIn;
}