package swfty.extra;

// TODO: Made for openfl display list for now...
class Debug {

    public static function traverse(sprite:Sprite) {
        #if (openfl && list)
        
        var display:openfl.display.DisplayObjectContainer = cast sprite;
        if (display == null) return;

        trace('Traversing ${display.name} (${display.numChildren})');

        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            var str = '';
            for (i in 0...depth) str += '-';

            var display:openfl.display.DisplayObjectContainer = cast sprite;
            if (display == null) return;
            
            trace('$str | ${display.name} (${display.numChildren}, ${display.x}, ${display.y})', display);
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

        traverseOpenFL(cast sprite);

        #end
    }

    public static function traverseParent(sprite:Sprite) {
        #if (openfl && list)
        
        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            if (sprite == null) return;
            
            var str = '';
            for (i in 0...depth) str += '-';
            
            if (Std.is(sprite, FinalSprite)) {
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.y})');
            } else {
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.y}) (DISPLAY OBJECT) (${sprite == openfl.Lib.current})');
            }

            if (sprite.parent != null) {
                traverseOpenFL(sprite.parent, depth + 1);
            }
        }

        traverseOpenFL(cast sprite);
        #end
    }

    public static function drawBounds(sprite:Sprite) {
        #if (openfl && list)
        // TODO: Draw bounds of each sprite with a random alpha color
        #end
    }
}