package swfty.extra;

import swfty.renderer.Sprite;

class Interaction {

    static inline var RENDER_ID = 'interaction';

    public static inline function click(sprite:Sprite, ?cache = true, f:Void->Void) {
        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds = sprite.calcBounds(sprite.layer.base);
        inline function getBounds() {
            if (!cache) bounds = sprite.calcBounds(sprite.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        sprite.addRender(RENDER_ID, function render(dt) {
            if (sprite.layer == null) return;

            var mouse = sprite.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                        if (getBounds().inside(x, y)) {
                            wasInside = true;
                        }
                    case Up : 
                        if (wasInside && getBounds().inside(x, y)) {
                            f();
                        }
                        wasInside = false;
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static inline function removeClick(sprite:Sprite) {
        sprite.removeRender(RENDER_ID);
        return sprite;
    }
}