package swfty.extra;

// TODO: Made for openfl for now...
class Debug {

    public static function autoPrint() {
        var timer = new haxe.Timer(5000);
        timer.run = function() {
            trace(print());
        }
    }

    public static function print() {
        var rstr = '';

        #if (openfl && list)
        var stage = openfl.Lib.current;

        var n = 0, movieClips = 0, childInLayer = 0, layers = 0, sprites = 0, bitmaps = 0, texts = 0, glyphs = 0, nonEmptyLayers = 0, textureMemory = 0;
        var bitmapsMemory = 0, bitmapDatas = 0, tilemaps = 0, drawCalls = 0;
        var layersName = '';

        var bmpds = new Map<openfl.display.BitmapData, Int>();

        function traverseText(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            var display:openfl.display.DisplayObjectContainer = cast sprite;
            if (display == null) return;

            for (i in 0...display.numChildren) {
                if (Std.is(display.getChildAt(i), openfl.display.DisplayObjectContainer)) {
                    n++;
                    traverseText(cast display.getChildAt(i), depth);
                } else {
                    // End
                    n++;

                    if (Std.is(display.getChildAt(i), openfl.display.Bitmap)) {
                        glyphs++;
                        bitmaps++;
                        drawCalls++;

                        var bitmap:openfl.display.Bitmap = cast display.getChildAt(i);
                        if (!bmpds.exists(bitmap.bitmapData)) {
                            bitmapDatas++;

                            var mem = bitmap.bitmapData.width * bitmap.bitmapData.height * 4;
                            bmpds.set(bitmap.bitmapData, mem);

                            bitmapsMemory += mem;
                        }
                    }
                }
            }
        }

        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            n++;
            
            if (Std.is(sprite, FinalLayer)) {
                var layer:FinalLayer = cast sprite;
                textureMemory += layer.textureMemory;

                if (layer.textureMemory > 0) {
                    nonEmptyLayers++;

                    var r = ~/([^\/\\]+)\.swfty/i;
                    r.match(layer.path);

                    try {
                        layersName += (layersName == '' ? '' : ', ') + r.matched(1);
                    } catch(e:Dynamic) {
                        if (layer.path != null && layer.path != '') {
                            layersName += (layersName == '' ? '' : ', ') + layer.path;
                        } else {
                            var display:openfl.display.DisplayObject = cast layer;
                            layersName += (layersName == '' ? '' : ', ') + 'no path (${display.name})';
                        }
                    }
                }
                
                layers++;
                childInLayer = 0;
            }

            var display:openfl.display.DisplayObjectContainer = cast sprite;
            if (display == null) return;

            for (i in 0...display.numChildren) {
                if (Std.is(display.getChildAt(i), FinalText)) {

                    texts++;
                    n++;
                    traverseText(cast display.getChildAt(i));


                } else if (Std.is(display.getChildAt(i), FinalSprite)) {
                    childInLayer++;
                    sprites++;
                    traverseOpenFL(cast display.getChildAt(i), depth + 1);
                } else {
                    var displayObject = display.getChildAt(i);

                    if (Std.is(displayObject, openfl.display.MovieClip)) {
                        n++;
                        movieClips++;
                        drawCalls++;

                    } else if (Std.is(displayObject, openfl.display.Tilemap)) {

                        n++;
                        tilemaps++;
                        drawCalls++;

                    } else if (Std.is(displayObject, openfl.display.DisplayObjectContainer)) {
                        traverseOpenFL(cast displayObject, depth);
                    } else {
                        // End
                        n++;

                        if (Std.is(displayObject, openfl.display.Bitmap)) {
                            bitmaps++;
                            drawCalls++;

                            var bitmap:openfl.display.Bitmap = cast display.getChildAt(i);
                            if (!bmpds.exists(bitmap.bitmapData)) {
                                bitmapDatas++;

                                try {
                                    var mem = bitmap.bitmapData.width * bitmap.bitmapData.height * 4;
                                    bmpds.set(bitmap.bitmapData, mem);

                                    bitmapsMemory += mem;
                                } catch(e:Dynamic) {
                                    
                                }
                            }
                        } else {
                            trace('Something else????', displayObject);
                        }
                    }
                }
            }
        }

        traverseOpenFL(cast stage);
    
        inline function round(n:Float):String {
            return '${(Math.round(n * 100) / 100)}';
        }

        var mem = openfl.system.System.totalMemory / 1024 / 1024;
        rstr += 'RAM: ${round(mem)} MB, Texture: ${round(textureMemory / 1024 / 1024)} MB, Layers: ${layers}, Non-empty layers: ${nonEmptyLayers}\n';
        rstr += 'Total: ${n}, MovieClips: ${movieClips}, Sprites: ${sprites}, Tilemaps: ${tilemaps}, Bitmaps: ${bitmaps}, Texts: ${texts}, Glyphs: ${glyphs}\n';
        rstr += 'Draw Calls: ${drawCalls}\n';
        rstr += 'Display List: ${bitmapDatas}, memory: ${round(bitmapsMemory / 1024 / 1024)} MB\n';
        
        if (swfty.extra.Manager.ref != null) {
            var str = '';
            var nLayer = 0;
            var texMem = 0;
            for (layer in swfty.extra.Manager.ref.layers) if (layer.loaded) {
                
                var r = ~/([^\/\\]+)\.swfty/i;
                r.match(layer.path);
                nLayer++;
                texMem += layer.textureMemory;

                try {
                    str += (str == '' ? '' : ', ') + r.matched(1);
                } catch(e:Dynamic) {
                    if (layer.path != null && layer.path != '') {
                        str += (str == '' ? '' : ', ') + layer.path;
                    } else {
                        var display:openfl.display.DisplayObject = cast layer;
                        str += (str == '' ? '' : ', ') + 'no path (${display.name})';
                    }
                }
            }

            rstr += 'Manager layers: ${nLayer} ($str) ${round(texMem / 1024 / 1024)} MB\n';
        }
        
        rstr += 'Layers: ${layersName}';

        //traverse(stage);

        #else

        var stage = openfl.Lib.current;

        var n = 0, movieClips = 0, childInLayer = 0, layers = 0, sprites = 0, bitmaps = 0, nonEmptyLayers = 0, textureMemory = 0;
        var bitmapsMemory = 0, bitmapDatas = 0, tilemaps = 0, drawCalls = 0;
        var layersName = '';

        var bmpds = new Map<openfl.display.BitmapData, Int>();

        function countTiles(layer:FinalLayer) {
            function count(container:openfl.display.TileContainer, n = 0) {
                for (i in 0...container.numTiles) {
                    var tile = container.getTileAt(i);
                    if (Std.is(tile, openfl.display.TileContainer)) {
                        n += count(cast tile);
                    } else {
                        n++;
                    }
                }

                return n;
            }

            return count(layer.base);
        }

        function traverseOpenFL(sprite:openfl.display.DisplayObjectContainer, depth = 0) {
            n++;
            
            var display:openfl.display.DisplayObjectContainer = cast sprite;
            if (display == null) return;

            for (i in 0...display.numChildren) {
                
                var displayObject = display.getChildAt(i);

                if (Std.is(displayObject, FinalLayer)) {

                    n++;

                    var layer:FinalLayer = cast displayObject;
                    textureMemory += layer.textureMemory;

                    if (layer.textureMemory > 0) {
                        nonEmptyLayers++;

                        var r = ~/([^\/\\]+)\.swfty/i;
                        r.match(layer.path);

                        try {
                            layersName += (layersName == '' ? '' : ', ') + r.matched(1) + ' (${countTiles(cast layer)})';
                        } catch(e:Dynamic) {
                            if (layer.path != null && layer.path != '') {
                                layersName += (layersName == '' ? '' : ', ') + layer.path + ' (${countTiles(cast layer)})';
                            } else {
                                var display:openfl.display.DisplayObject = cast layer;
                                layersName += (layersName == '' ? '' : ', ') + 'no path (${display.name})';
                            }
                        }
                    }
                    
                    layers++;
                    drawCalls++;
                    childInLayer = 0;

                } else if (Std.is(displayObject, openfl.display.Tilemap)) {

                    n++;
                    tilemaps++;
                    drawCalls++;

                } else if (Std.is(displayObject, openfl.display.MovieClip)) {
                    n++;
                    movieClips++;
                    drawCalls++;

                } else if (Std.is(displayObject, openfl.display.DisplayObjectContainer)) {
                    traverseOpenFL(cast displayObject, depth);
                } else {
                    // End
                    n++;

                    if (Std.is(displayObject, openfl.display.Bitmap)) {
                        bitmaps++;
                        drawCalls++;

                        var bitmap:openfl.display.Bitmap = cast display.getChildAt(i);
                        if (!bmpds.exists(bitmap.bitmapData)) {
                            bitmapDatas++;

                            try {
                                var mem = bitmap.bitmapData.width * bitmap.bitmapData.height * 4;
                                bmpds.set(bitmap.bitmapData, mem);

                                bitmapsMemory += mem;
                            } catch(e:Dynamic) {
                                
                            }
                        }
                    }
                }
            }
        }

        traverseOpenFL(cast stage);
    
        inline function round(n:Float):String {
            return '${(Math.round(n * 100) / 100)}';
        }

        var mem = openfl.system.System.totalMemory / 1024 / 1024;
        rstr += 'RAM: ${round(mem)} MB, Texture: ${round(textureMemory / 1024 / 1024)} MB, Layers: ${layers}, Non-empty layers: ${nonEmptyLayers}\n';
        rstr += 'Total: ${n}, MovieClips: ${movieClips}, Sprites: ${sprites}, Tilemaps: ${tilemaps}, Bitmaps: ${bitmaps}\n';
        rstr += 'Draw Calls: ${drawCalls}\n';
        if (bitmapDatas > 0 ) rstr += 'Display List: ${bitmapDatas}, memory: ${round(bitmapsMemory / 1024 / 1024)} MB\n';
        
        if (swfty.extra.Manager.ref != null) {
            var str = '';
            var nLayer = 0;
            var texMem = 0;
            for (layer in swfty.extra.Manager.ref.layers) if (layer.loaded) {
                
                var r = ~/([^\/\\]+)\.swfty/i;
                r.match(layer.path);
                nLayer++;
                texMem += layer.textureMemory;

                try {
                    str += (str == '' ? '' : ', ') + r.matched(1) + ' (${countTiles(cast layer)})';
                } catch(e:Dynamic) {
                    if (layer.path != null && layer.path != '') {
                        str += (str == '' ? '' : ', ') + layer.path + ' (${countTiles(cast layer)})';
                    } else {
                        var display:openfl.display.DisplayObject = cast layer;
                        str += (str == '' ? '' : ', ') + 'no path (${display.name})';
                    }
                }
            }

            rstr += 'Manager layers: ${nLayer} ($str) ${round(texMem / 1024 / 1024)} MB\n';
        }
        
        rstr += 'Layers: ${layersName}';

        #end

        return rstr;
    }

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
                        traverseOpenFL(cast displayObject, depth + 1);
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
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.scaleX}, ${sprite.y}, ${sprite.alpha}, ${sprite.visible}, ${bounds})');
            } else {
                trace('$str | ${sprite.name} (${sprite.numChildren}, ${sprite.x}, ${sprite.scaleX}, ${sprite.y}, ${sprite.alpha}, ${sprite.visible}, ${bounds}) (DISPLAY OBJECT) (${sprite == openfl.Lib.current})');
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