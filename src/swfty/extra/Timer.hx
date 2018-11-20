package swfty.extra;

import swfty.renderer.Sprite;

using swfty.extra.Timer;

class Timer {

    static inline var RENDER_ID = 'wait';

    public static inline function wait(sprite:Sprite, duration:Float, ?stop = false, ?onComplete:Void->Void) {
        if (stop) sprite.waitStop();
        
        var time = 0.0;
        sprite.addRender(RENDER_ID, function render(dt) {
            if (time >= duration) {
                time = duration;
                sprite.removeRender(RENDER_ID, render);

                if (onComplete != null) onComplete();
            }

            time += dt;
        });

        return sprite;
    }

    public static inline function waitStop(sprite:Sprite) {
        sprite.removeRender(RENDER_ID);
        return sprite;
    }
}