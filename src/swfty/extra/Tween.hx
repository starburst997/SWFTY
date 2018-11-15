package swfty.extra;

import swfty.renderer.Sprite;

using tweenxcore.Tools;

using swfty.extra.Tween;
using swfty.extra.Lambda;

// Very simple tween meant for SWFTY Sprite (optional extra)
// Nothing fancy and hooks on the update loop of the Sprite
// Will die with the sprite or when it finishes running
// Not exactly super mega optimised, but should do the job just fine

class Tween {

    /* Presets */

    public static inline function fadeIn(sprite:Sprite, duration:Float = 0.30, ?delay = 0.0, ?stop:Bool = true) {
        if (!sprite.visible) {
            sprite.visible = true;
            sprite.alpha = 0.0;
        }

        if (stop) sprite.tweenStop();
        
        sprite.tweenAlpha(1.0, duration, delay);
        return sprite;
    }

    public static inline function fadeOut(sprite:Sprite, duration:Float = 0.20, ?delay = 0.0, ?stop:Bool = true, ?remove:Bool = false) {
        if (stop) sprite.tweenStop();
        
        sprite.tweenAlpha(0.0, duration, delay, function() {
            sprite.visible = false;
        });
        if (remove) sprite.wait(duration + delay, function() {
            sprite.removeFromParent();
        });
        return sprite;
    }

    public static inline function pop(sprite:Sprite, ?strength:Float = 2.50, duration:Float = 0.20, ?delay = 0.0, ?stop:Bool = true) {
        if (stop) sprite.tweenStop();
        
        sprite
        .tweenScale(sprite.scaleX * strength, duration, delay, BackOut)
        .tweenAlpha(0.0, duration, delay);

        sprite.wait(duration + delay, function() {
            sprite.removeFromParent();
        });
        return sprite;
    }

    public static inline function popToward(sprite:Sprite, to:Sprite, ?strength:Float = 2.50, duration:Float = 0.75, ?delay = 0.0, ?stop:Bool = true, ?onComplete:Void->Void) {
        // TODO: Use getBounds with target space
        return popTowardPosition(sprite, to.x, to.y, strength, duration, delay, stop, onComplete);
    }

    public static inline function popTowardPosition(sprite:Sprite, x:Float, y:Float, duration:Float = 0.75, ?delay = 0.0, ?strength:Float = 2.50, ?stop:Bool = true, ?onComplete:Void->Void) {
        if (stop) sprite.tweenStop();

        sprite
        .tweenAlpha(0.10, duration * 0.25, delay + duration * 0.75)
        .towardPosition(x, y, duration, delay, false, function() {
            sprite.pop(strength, 0.2);
            if (onComplete != null) onComplete();
        });
        return sprite;
    }

    public static inline function fadeToward(sprite:Sprite, to:Sprite, duration:Float = 0.50, ?delay:Float = 0.0, ?stop:Bool = true, ?onComplete:Void->Void) {
        // TODO: Use getBounds with target space
        return sprite.fadeTowardPosition(to.x, to.y, duration, delay, stop, onComplete);
    }

    public static inline function fadeTowardPosition(sprite:Sprite, x:Float, y:Float, duration:Float = 0.50, ?delay:Float = 0.0, ?stop:Bool = true, ?onComplete:Void->Void) {
        if (stop) sprite.tweenStop();

        sprite
        .tweenPosition(x, y, duration, delay, BackIn)
        .tweenScale(0.0, duration * 0.10, delay + duration * 0.90, BackIn)
        .tweenAlpha(0.0, duration * 0.025, delay + duration * 0.975, function() {
            
            if (onComplete != null) onComplete();
        });

        sprite.wait(duration + delay, function() {
            sprite.removeFromParent();
        });
        return sprite;
    }

    public static inline function toward(sprite:Sprite, to:Sprite, duration:Float = 0.50, ?delay:Float = 0.0, ?stop:Bool = true, ?onComplete:Void->Void) {
        if (stop) sprite.tweenStop();

        sprite.tweenPosition(to.x, to.y, duration, delay, BackIn, onComplete);
        return sprite;
    }

    public static inline function towardPosition(sprite:Sprite, x:Float, y:Float, duration:Float = 0.50, ?delay:Float = 0.0, ?stop:Bool = true, ?onComplete:Void->Void) {
        if (stop) sprite.tweenStop();

        sprite.tweenPosition(x, y, duration, delay, BackIn, onComplete);
        return sprite;
    }

    public static inline function bounce(sprite:Sprite, to = 1.0, strength = 1.20, duration:Float = 0.5, ?delay = 0.0, ?stop = true, ?stack = false, ?max = 0.0, ?onComplete:Void->Void) {
        if (stop) sprite.tweenStop();

        var scale = (stack ? sprite.scaleX : to) * strength;
        if (stack && max > 0 && scale > to * max) scale = to * max;

        sprite.tweenScale(scale, duration * 0.20, delay, CubicIn, function() {
            sprite.tweenScale(to, duration * 0.80, BounceOut);
            if (onComplete != null) onComplete();
        });
        return sprite;
    }

    /* Timer */

    // TODO: Should be moved to it's own class tools

    public static inline function wait(sprite:Sprite, duration:Float, ?stop = false, ?onComplete:Void->Void) {
        if (stop) sprite.waitStop();
        
        var time = 0.0;
        sprite.addRender('wait', function render(dt) {
            if (time >= duration) {
                time = duration;
                sprite.removeRender('wait', render);

                if (onComplete != null) onComplete();
            }

            time += dt;
        });

        return sprite;
    }

    public static inline function waitStop(sprite:Sprite) {
        sprite.removeRender('wait');
        return sprite;
    }

    /* Tween */

    public static inline function tweenWidth(sprite:Sprite, width:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.width, width, duration, delay, easing, onComplete, function(val) {
            sprite.width = val;
        });
        return sprite;
    }

    public static inline function tweenHeight(sprite:Sprite, height:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.height, height, duration, delay, easing, onComplete, function(val) {
            sprite.height = val;
        });
        return sprite;
    }

    public static inline function tweenScale(sprite:Sprite, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleX, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleX = sprite.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenScaleX(sprite:Sprite, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleX, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleX = val;
        });
        return sprite;
    }

    public static inline function tweenScaleY(sprite:Sprite, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.scaleY, scale, duration, delay, easing, onComplete, function(val) {
            sprite.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenX(sprite:Sprite, x:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.x, x, duration, delay, easing, onComplete, function(val) {
            sprite.x = val;
        });
        return sprite;
    }

    public static inline function tweenY(sprite:Sprite, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.y, y, duration, delay, easing, onComplete, function(val) {
            sprite.y = val;
        });
        return sprite;
    }

    public static inline function tweenAlpha(sprite:Sprite, alpha:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.alpha, alpha, duration, delay, easing, onComplete, function(val) {
            sprite.alpha = val;
        });
        return sprite;
    }

    public static inline function tweenRotation(sprite:Sprite, angle:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        setup(sprite, sprite.rotation, angle, duration, delay, easing, onComplete, function(val) {
            sprite.rotation = val;
        });
        return sprite;
    }

    public static inline function tweenPosition(sprite:Sprite, x:Float, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void) {
        tweenX(sprite, x, duration, delay, easing, onComplete);
        tweenY(sprite, y, duration, delay, easing, onComplete);
        return sprite;
    }

    public static inline function tweenStop(sprite:Sprite) {
        sprite.removeRender('tween');
        return sprite;
    }

    /* Helpers */

    static inline function setup(sprite:Sprite, from:Float, to:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?onComplete:Void->Void, setVal:Float->Void) {
        var ease = getEasing(from, to, easing);
        var time = delay == null ? 0.0 : -delay;
        var done = false;
        sprite.addRender('tween', function render(dt) {
            if (time >= duration) {
                time = duration;
                done = true;
                sprite.removeRender('tween', render);
            }

            if (time >= 0.0) setVal(ease(time / duration));
            time += dt;
            
            if (done && onComplete != null) onComplete();
        });
    }

    static inline function getEasing(from:Float, to:Float, ?easing:Easing) {
        return switch(easing) {
            case SineIn: function(rate:Float) {
                return rate.sineIn().lerp(from, to);
            };
            case SineOut: function(rate:Float) {
                return rate.sineOut().lerp(from, to);
            };
            case SineInOut: function(rate:Float) {
                return rate.sineInOut().lerp(from, to);
            };
            case SineOutIn: function(rate:Float) {
                return rate.sineOutIn().lerp(from, to);
            };
            case QuadIn: function(rate:Float) {
                return rate.quadIn().lerp(from, to);
            };
            case QuadOut: function(rate:Float) {
                return rate.quadOut().lerp(from, to);
            };
            case QuadInOut: function(rate:Float) {
                return rate.quadInOut().lerp(from, to);
            };
            case QuadOutIn: function(rate:Float) {
                return rate.quadOutIn().lerp(from, to);
            };
            case CubicIn: function(rate:Float) {
                return rate.cubicIn().lerp(from, to);
            };
            case CubicOut: function(rate:Float) {
                return rate.cubicOut().lerp(from, to);
            };
            case CubicInOut: function(rate:Float) {
                return rate.cubicInOut().lerp(from, to);
            };
            case CubicOutIn: function(rate:Float) {
                return rate.cubicOutIn().lerp(from, to);
            };
            case QuartIn: function(rate:Float) {
                return rate.quartIn().lerp(from, to);
            };
            case QuartOut: function(rate:Float) {
                return rate.quartOut().lerp(from, to);
            };
            case QuartInOut: function(rate:Float) {
                return rate.quartInOut().lerp(from, to);
            };
            case QuartOutIn: function(rate:Float) {
                return rate.quartOutIn().lerp(from, to);
            };
            case QuintIn: function(rate:Float) {
                return rate.quintIn().lerp(from, to);
            };
            case QuintOut: function(rate:Float) {
                return rate.quintOut().lerp(from, to);
            };
            case QuintInOut: function(rate:Float) {
                return rate.quintInOut().lerp(from, to);
            };
            case QuintOutIn: function(rate:Float) {
                return rate.quintOutIn().lerp(from, to);
            };
            case ExpoIn: function(rate:Float) {
                return rate.expoIn().lerp(from, to);
            };
            case ExpoOut: function(rate:Float) {
                return rate.expoOut().lerp(from, to);
            };
            case ExpoInOut: function(rate:Float) {
                return rate.expoInOut().lerp(from, to);
            };
            case ExpoOutIn: function(rate:Float) {
                return rate.expoOutIn().lerp(from, to);
            };
            case CircIn: function(rate:Float) {
                return rate.circIn().lerp(from, to);
            };
            case CircOut: function(rate:Float) {
                return rate.circOut().lerp(from, to);
            };
            case CircInOut: function(rate:Float) {
                return rate.circInOut().lerp(from, to);
            };
            case CircOutIn: function(rate:Float) {
                return rate.circOutIn().lerp(from, to);
            };
            case BounceIn: function(rate:Float) {
                return rate.bounceIn().lerp(from, to);
            };
            case BounceOut: function(rate:Float) {
                return rate.bounceOut().lerp(from, to);
            };
            case BounceInOut: function(rate:Float) {
                return rate.bounceInOut().lerp(from, to);
            };
            case BounceOutIn: function(rate:Float) {
                return rate.bounceOutIn().lerp(from, to);
            };
            case BackIn: function(rate:Float) {
                return rate.backIn().lerp(from, to);
            };
            case BackOut: function(rate:Float) {
                return rate.backOut().lerp(from, to);
            };
            case BackInOut: function(rate:Float) {
                return rate.backInOut().lerp(from, to);
            };
            case BackOutIn: function(rate:Float) {
                return rate.backOutIn().lerp(from, to);
            };
            case ElasticIn: function(rate:Float) {
                return rate.elasticIn().lerp(from, to);
            };
            case ElasticOut: function(rate:Float) {
                return rate.elasticOut().lerp(from, to);
            };
            case ElasticInOut: function(rate:Float) {
                return rate.elasticInOut().lerp(from, to);
            };
            case ElasticOutIn: function(rate:Float) {
                return rate.elasticOutIn().lerp(from, to);
            };
            case WarpOut: function(rate:Float) {
                return rate.warpOut().lerp(from, to);
            };
            case WarpIn: function(rate:Float) {
                return rate.warpIn().lerp(from, to);
            };
            case WarpInOut: function(rate:Float) {
                return rate.warpInOut().lerp(from, to);
            };
            case WarpOutIn: function(rate:Float) {
                return rate.warpOutIn().lerp(from, to);
            };
            case Linear, _: function(rate:Float) {
                return rate.linear().lerp(from, to);
            }
        }
    }
}

class TweenText {
    public static inline function bounce(text:Text, to = 1.0, strength = 1.20, duration:Float = 0.5, ?delay = 0.0, ?onComplete:Void->Void) {
        return Tween.bounce(text.sprite(), to, strength, duration, delay, onComplete);
    }

    // TODO: Also do all the other methods
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