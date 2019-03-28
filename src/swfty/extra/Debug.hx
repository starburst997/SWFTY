package swfty.extra;

// TODO: Made for openfl display list for now...
class Debug {

    public static function traverse(?sprite:Sprite, ?layer:Layer, ?flash:openfl.display.DisplayObjectContainer) {
        #if (openfl && list)
        
        var display:openfl.display.DisplayObjectContainer = null;

        if (sprite != null) display = cast sprite;
        if (layer != null) display = cast layer;
        if (flash != null) display = cast flash;
        
        if (display == null) return;

        trace('Traversing ${display.name} (${display.numChildren})');

        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            var str = '';
            for (i in 0...depth) str += '-';

            var display:openfl.display.DisplayObjectContainer = cast sprite;
            if (display == null) return;
            
            var bounds = display.getBounds(openfl.Lib.current);

            trace('$str | ${display.name} (${display.numChildren}, ${display.x}, ${display.y}, ${display.alpha}, ${display.visible}, ${bounds})', display);
            for (i in 0...display.numChildren) {
                if (Std.is(display.getChildAt(i), FinalSprite)) {
                    traverseOpenFL(cast display.getChildAt(i), depth + 1);
                } else {
                    var displayObject = display.getChildAt(i);

                    if (Std.is(displayObject, openfl.display.DisplayObjectContainer)) {
                        traverseOpenFL(cast displayObject, depth);
                    } else {
                        trace('$str- | ${displayObject.name} (DISPLAY OBJECT END)');
                    }
                }
            }
        }

        if (sprite != null) traverseOpenFL(cast sprite);
        if (layer != null) traverseOpenFL(cast layer);
        if (flash != null) traverseOpenFL(cast flash);
        #end
    }

    public static function traverseParent(?sprite:Sprite, ?layer:Layer, ?flash:openfl.display.DisplayObjectContainer) {
        #if (openfl && list)
        
        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            if (sprite == null) return;
            
            var str = '';
            for (i in 0...depth) str += '-';
            
            var bounds = sprite.getBounds(openfl.Lib.current);

            if (Std.is(sprite, FinalSprite)) {
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.y}, ${sprite.alpha}, ${sprite.visible}, ${bounds})');
            } else {
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.y}, ${sprite.alpha}, ${sprite.visible}, ${bounds}) (DISPLAY OBJECT) (${sprite == openfl.Lib.current})');
            }

            if (sprite.parent != null) {
                traverseOpenFL(sprite.parent, depth + 1);
            }
        }

        if (sprite != null) traverseOpenFL(cast sprite);
        if (layer != null) traverseOpenFL(cast layer);
        if (flash != null) traverseOpenFL(cast flash);
        #end
    }

    public static function drawBounds(sprite:Sprite) {
        #if (openfl && list)
        // TODO: Draw bounds of each sprite with a random alpha color
        #end
    }
}