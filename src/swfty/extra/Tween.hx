package swfty.extra;

import swfty.renderer.Sprite;

using tweenxcore.Tools;

using swfty.extra.Tween;
using swfty.extra.Lambda;
using swfty.extra.Timer;

// Very simple tween meant for SWFTY Sprite (optional extra)
// Nothing fancy and hooks on the update loop of the Sprite
// Will die with the sprite or when it finishes running
// Not exactly super mega optimised, but should do the job just fine

enum Repeat {
    Once;
    Infinite;
    Yoyo;
    Repeat(n:Int);
}

class Tween {

    static inline var RENDER_ID = 'tween';

    /* Presets */

    public static inline function fadeIn(sprite:Sprite, ?duration:Float = 0.30, ?delay = 0.0, ?startFromZero = false, ?stop:Bool = true) {
        if (!sprite.visible || startFromZero) {
            sprite.visible = true;
            sprite.alpha = 0.0;
        }

        if (stop) sprite.tweenStop();
        
        sprite.tweenAlpha(1.0, duration, delay);
        return sprite;
    }

    public static inline function fadeOut(sprite:Sprite, ?duration:Float = 0.20, ?delay = 0.0, ?stop:Bool = true, ?remove:Bool = false) {
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

    /* Tween */

    public static inline function tweenFromWidth(sprite:Sprite, ?name:String, width:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.width;
        child.width = width;
        return tweenWidth(child, name, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromHeight(sprite:Sprite, ?name:String, height:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.height;
        child.height = height;
        return tweenHeight(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromScale(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.scaleX;
        child.scaleX = child.scaleY = scale;
        return tweenScale(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFomScaleXY(sprite:Sprite, ?name:String, scaleX:Float, scaleY:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        return sprite 
        .tweenFromScaleX(name, scaleX, duration, delay, easing, repeat)
        .tweenFromScaleY(name, scaleY, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromScaleX(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.scaleX;
        child.scaleX = scale;
        return tweenScaleX(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromScaleY(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.scaleY;
        child.scaleY = scale;
        return tweenScaleY(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromX(sprite:Sprite, ?name:String, x:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.x;
        child.x = x;
        return tweenX(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromY(sprite:Sprite, ?name:String, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.y;
        child.y = y;
        return tweenY(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromAlpha(sprite:Sprite, ?name:String, alpha:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.alpha;
        child.alpha = alpha;
        return tweenAlpha(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromRotation(sprite:Sprite, ?name:String, angle:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        var value = child.rotation;
        child.rotation = angle;
        return tweenAlpha(child, value, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenFromPosition(sprite:Sprite, ?name:String, x:Float, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        tweenFromY(sprite, name, y, duration, delay, easing, repeat);
        tweenFromX(sprite, name, x, duration, delay, easing, repeat, onComplete);
        return sprite;
    }

    public static inline function tweenFromDimension(sprite:Sprite, ?name:String, width:Float, height:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        tweenFromWidth(sprite, name, width, duration, delay, easing, repeat);
        tweenFromHeight(sprite, name, height, duration, delay, easing, repeat, onComplete);
        return sprite;
    }

    public static inline function tweenWidth(sprite:Sprite, ?name:String, width:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.width, width, duration, delay, easing, repeat, onComplete, function(val) {
            child.width = val;
        });
        return sprite;
    }

    public static inline function tweenHeight(sprite:Sprite, ?name:String, height:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.height, height, duration, delay, easing, repeat, onComplete, function(val) {
            child.height = val;
        });
        return sprite;
    }

    public static inline function tweenScale(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.scaleX, scale, duration, delay, easing, repeat, onComplete, function(val) {
            child.scaleX = child.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenScaleXY(sprite:Sprite, ?name:String, scaleX:Float, scaleY:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        return sprite 
        .tweenScaleX(name, scaleX, duration, delay, easing, repeat)
        .tweenScaleY(name, scaleY, duration, delay, easing, repeat, onComplete);
    }

    public static inline function tweenScaleX(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.scaleX, scale, duration, delay, easing, repeat, onComplete, function(val) {
            child.scaleX = val;
        });
        return sprite;
    }

    public static inline function tweenScaleY(sprite:Sprite, ?name:String, scale:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.scaleY, scale, duration, delay, easing, repeat, onComplete, function(val) {
            child.scaleY = val;
        });
        return sprite;
    }

    public static inline function tweenX(sprite:Sprite, ?name:String, x:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.x, x, duration, delay, easing, repeat, onComplete, function(val) {
            child.x = val;
        });
        return sprite;
    }

    public static inline function tweenY(sprite:Sprite, ?name:String, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.y, y, duration, delay, easing, repeat, onComplete, function(val) {
            child.y = val;
        });
        return sprite;
    }

    public static inline function tweenAlpha(sprite:Sprite, ?name:String, alpha:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.alpha, alpha, duration, delay, easing, repeat, onComplete, function(val) {
            child.alpha = val;
        });
        return sprite;
    }

    public static inline function tweenRotation(sprite:Sprite, ?name:String, angle:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);
        setup(child, child.rotation, angle, duration, delay, easing, repeat, onComplete, function(val) {
            child.rotation = val;
        });
        return sprite;
    }

    public static inline function tweenPosition(sprite:Sprite, ?name:String, x:Float, y:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        tweenY(sprite, name, y, duration, delay, easing, repeat);
        tweenX(sprite, name, x, duration, delay, easing, repeat, onComplete);
        return sprite;
    }

    public static inline function tweenDimension(sprite:Sprite, ?name:String, width:Float, height:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void) {
        tweenWidth(sprite, name, width, duration, delay, easing, repeat);
        tweenHeight(sprite, name, height, duration, delay, easing, repeat, onComplete);
        return sprite;
    }

    public static inline function tweenStop(sprite:Sprite, ?name:String) {
        var child = name == null ? sprite : sprite.get(name);
        child.removeRender(RENDER_ID);
        return sprite;
    }

    /* Helpers */

    // Repeat = -1 is infinite repeat
    // TODO: Create abstract Enums over Int for "repeat" params
    static inline function setup(sprite:Sprite, from:Float, to:Float, duration:Float, ?delay:Float = 0.0, ?easing:Easing, ?repeat:Int = 0, ?onComplete:Void->Void, setVal:Float->Void) {
        // If duration is 0 we assume it's immediate
        if (duration == 0.0) {
            sprite.wait(delay, function() {
                setVal(to);
                if (onComplete != null) onComplete();
            });
        } else {
            var ease = getEasing(from, to, easing);
            var time = delay == null ? 0.0 : -delay;
            var done = false;
            
            sprite.addRender(RENDER_ID, function render(dt) {
                if (time >= duration) {
                    time = duration;
                    done = true;
                    if (repeat-- == 0) sprite.removeRender(RENDER_ID, render);
                } else if ((repeat != 0) && done && time <= -delay) {
                    time = -delay;
                    done = false;
                }

                if (time >= 0.0) setVal(ease(time / duration));
                
                if (done) {
                    if (time > 0 && time - dt < 0 && repeat > 0) setVal(ease(0));
                    time -= dt;
                } else {
                    time += dt;
                }
                
                if (done && (repeat == -1) && onComplete != null) onComplete();
            });
        }
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

@:access(swfty.extra.Tween)
class TweenText {
    public static inline function bounce(text:Text, ?to = 1.0, ?strength = 1.20, ?duration:Float = 0.5, ?delay = 0.0, ?onComplete:Void->Void) {
        return Tween.bounce(text.sprite(), to, strength, duration, delay, onComplete);
    }

    // Require the Sprite to have a "label" child
    public static inline function incrementBounce(sprite:Sprite, i:Int, ?duration:Float = 0.5, ?delay = 0.0, ?onComplete:Void->Void) {
        // Too small to bother
        if (i <= 3) {
            sprite.getText('label').text = '$i';
            if (onComplete != null) onComplete();
            return;
        }
        
        var current = 0;
        var time = duration / i;
        var timer = 0.0;

        sprite.getText('label').text = '$current';
        
        sprite.addRender(Tween.RENDER_ID, function render(dt) {
            timer += dt;
            if (timer >= time) {
                current += Math.floor(timer / time);
                timer -= Math.floor(timer / time) * time;
                
                if (current >= i) {
                    current = i;
                    sprite.removeRender(Tween.RENDER_ID, render);
                }

                sprite.getText('label').text = '$current';
                sprite.bounce(1.0, 1.0 + 0.05 * Math.min(1 - current / 200, 1.00001), 0.40, false, true, 2.5, current >= i ? onComplete : null);
            }
        });
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