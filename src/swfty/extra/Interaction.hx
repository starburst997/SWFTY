package swfty.extra;

import swfty.renderer.Sprite;

using swfty.extra.Tween;

class Interaction {

    static inline var RENDER_ID = 'interaction';

    public static function click(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
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

    public static function mouseDown(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                        if (getBounds().inside(x, y)) {
                            if (!wasInside) f();
                            wasInside = true;
                        }
                    case Up : 
                        wasInside = false;
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseUp(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                    case Up : 
                        if (getBounds().inside(x, y)) {
                            f();
                        }
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseUpAnywhere(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // Detect left click inside and wait for mouse up inside to trigger handler
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                switch(mouse.left) {
                    case Down : 
                    case Up : f();
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static inline function clickOnce(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        click(sprite, name, cache, function() {
            removeClick(sprite, name);
            f();
        });
    }

    public static function fancyClick(sprite:Sprite, ?name:String, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // TODO: Add a quick tween on "down" and when "up", like scale down a bit with a bounce then scale back up

        return sprite;
    }

    // TODO: Should we specify the function?
    public static inline function removeClick(sprite:Sprite, ?name:String) {
        var child = name == null ? sprite : sprite.get(name);

        child.removeRender(RENDER_ID);
        return sprite;
    }
}