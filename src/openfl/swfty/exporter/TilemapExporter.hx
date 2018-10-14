package openfl.swfty.exporter;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import binpacking.SimplifiedMaxRectsPacker;

typedef Tile = {
    id: Int,
    x: Int,
    y: Int,
    width: Int,
    height: Int
}

typedef TilePack = {
    tiles: Array<Tile>,
    bitmapData: BitmapData
}

typedef TrimBitmap = {
    bmpd: BitmapData,
    rect: Rectangle,
    originalWidth: Int,
    originalHeight: Int
}

class TilemapExporter {

    public static function trim(bmpd:BitmapData):TrimBitmap {
        var originalWidth = bmpd.width;
        var originalHeight = bmpd.height;
       
        var notAlphaBounds = bmpd.getColorBoundsRect(0xFF000000, 0x00000000, false);
        var trimed = new BitmapData(Std.int(notAlphaBounds.width), Std.int(notAlphaBounds.height), true, 0x00000000);
        trimed.copyPixels(bmpd, notAlphaBounds, new Point());
        bmpd.dispose();

        // Save trimmed bmpd
        return {bmpd: trimed, rect: notAlphaBounds, originalWidth: originalWidth, originalHeight: originalHeight};
    }

    public static function pack(bmpds:Array<BitmapData>, w:Int = 128, h:Int = 128, ?trimBitmap = true) {

        function createPack(w:Int, h:Int) {
            var tiles:Array<Tile> = [];
            var pack = new SimplifiedMaxRectsPacker(w, h);
            return try {
                for (i in 0...bmpds.length) {
                    var bmpd = bmpds[i];
                    var padding = 1;
                    var rect = if (bmpd != null)
                        pack.insert(bmpd.width + padding * 2, bmpd.height + padding * 2)
                    else 
                        pack.insert(1, 1);

                    if (rect == null) {
                        throw 'Not enough space';
                    } else {
                        tiles.push({
                            id: i,
                            x: Std.int(rect.x) + padding,
                            y: Std.int(rect.y) + padding,
                            width: Std.int(rect.width) - padding*2,
                            height: Std.int(rect.height) - padding*2
                        });
                    }
                }

                tiles;
            } catch(e:Dynamic) {
                null;
            }
        }

        var tiles:Array<Tile> = null;
        while (w <= 65536 && h <= 65536) { // Don't go too far
            tiles = createPack(w, h);
            if (tiles == null) {
                if (w == h) {
                    w *= 2;
                } else {
                    h *= 2;
                }
                //trace('Trying $w, $h...');
            } else {
                break;
            }
        }

        return if (tiles != null) {
            var bitmapData = new BitmapData(w, h, true, 0x00000000);
            for (i in 0...tiles.length) {
                var tile = tiles[i];
                var bmpd = bmpds[i];
                if (bmpd != null) bitmapData.copyPixels(bmpd, bmpd.rect, new Point(tile.x, tile.y));
                //bmpd.dispose();
            };

            // Trim final texture
            if (trimBitmap) {
                bitmapData.setPixel32(0, 0, 0xFF000000);
                var trimmed = trim(bitmapData);
                bitmapData.dispose();
                bitmapData = trimmed.bmpd;
                bitmapData.setPixel32(0, 0, 0x00000000);
            }
            
            {tiles: tiles, bitmapData: bitmapData};
        } else {
            null;
        }
    }
}