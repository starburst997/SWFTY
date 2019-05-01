package openfl.swfty.exporter;

import haxe.ds.IntMap;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
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
    scale: Float,
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
       
        var notAlphaBounds = bmpd.getColorBoundsRect(0xF0000000, 0x00000000, false);
        var trimed = new BitmapData(Std.int(notAlphaBounds.width), Std.int(notAlphaBounds.height), true, 0x00000000);
        trimed.copyPixels(bmpd, notAlphaBounds, new Point());
        bmpd.dispose();

        // Save trimmed bmpd
        return {bmpd: trimed, rect: notAlphaBounds, originalWidth: originalWidth, originalHeight: originalHeight};
    }

    public static function fit(bmpds:Array<BitmapData>, w:Int, h:Int, scale = 1.0, ?trimBitmap = true, ?forceDimension = false) {
        var original = bmpds;

        #if sys
        // Save all bitmaps to temp folder and use ImageMagick to resize
        var temp = Exporter.tempFolder;
        FileUtils.createDirectory(temp, true);
        FileUtils.createDirectory('$temp/original', true);

        for (i in 0...bmpds.length) {
            var bmpd = bmpds[i];
            if (bmpd.rect.width > 0 && bmpd.rect.height > 0) {
                var png = bmpd.encode(bmpd.rect, new PNGEncoderOptions());
                if (png.length > 0) {
                    FileUtils.createFile('$temp/original/$i.png', png);
                }
            }
        }
        #end

        var tilemap = null;
        while (tilemap == null) {
            if (scale != 1.0) {
                #if sys
                bmpds = [];
                FileUtils.createDirectory('$temp/scaled', true);
                for (i in 0...original.length) {
                    if (FileUtils.exists('$temp/original/$i.png')) {
                        Sys.command('convert $temp/original/$i.png -resize ${Std.int(scale * 100)}% $temp/scaled/$i.png');
                        
                        var bmpdBytes = sys.io.File.getBytes('$temp/scaled/$i.png');
                        var bmpd = BitmapData.fromBytes(bmpdBytes);
                        bmpds.push(bmpd);
                    } else {
                        bmpds.push(new BitmapData(1, 1, true, 0x00000000));
                    }
                }
                #else
                // TODO: image.resize(Std.int(image.width * scale), Std.int(image.height * scale));
                #end
            }
            
            trace('TESTING: $w, $h, $scale, $forceDimension');
            if (forceDimension) {
                tilemap = pack(bmpds, w, h, w, h, scale, trimBitmap);
            } else {
                tilemap = pack(bmpds, 128, 128, w, h, scale, trimBitmap);
            }
            
            scale -= 0.05;
        }

        #if sys
        //sFileUtils.deleteDirectory(temp);
        #end

        return tilemap;
    }

    public static function pack(bmpds:Array<BitmapData>, w:Int = 128, h:Int = 128, ?maxW:Int, ?maxH:Int, ?scale = 1.0, ?trimBitmap = true) {

        // Keep a copy of the unsorted array
        var copy = bmpds.copy();

        // Sort by area
        bmpds.sortdf(function(bmpd) return bmpd.width * bmpd.height);

        // Sort by area so we try to fit the biggest first then smaller one can fill in the gaps
        var area = 0;
        var map = new Map<BitmapData, Int>();
        for (i in 0...bmpds.length) {
            var bmpd = bmpds[i];
            map.set(bmpd, i);

            area += bmpd.width * bmpd.height;
        }

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
                    if (maxW == null || w < maxW) {
                        w *= 2;
                    } else {
                        break;
                    }
                } else if (maxH == null || h < maxH) {
                    h *= 2;
                } else {
                    break;
                }
                //trace('Trying $w, $h...');
            } else {
                break;
            }
        }

        return if (tiles != null) {
            var bitmapData = new BitmapData(w, h, true, 0x00000000);
            var sortedTiles = [];
            
            for (bmpdCopy in copy) {
                var i = map.get(bmpdCopy); // TODO: Is bmpds.indexOf(bmpdCopy) faster? My guess is no....
                var tile = tiles[i];
                var bmpd = bmpds[i];
                if (bmpd != null) bitmapData.copyPixels(bmpd, bmpd.rect, new Point(tile.x, tile.y));
                //bmpd.dispose();

                // We want to keep the original order
                sortedTiles.push(tile);
            };

            // Trim final texture
            if (trimBitmap) {
                bitmapData.setPixel32(0, 0, 0xFF000000);
                var trimmed = trim(bitmapData);
                bitmapData.dispose();
                bitmapData = trimmed.bmpd;
                bitmapData.setPixel32(0, 0, 0x00000000);
            }
            
            {tiles: sortedTiles, scale: scale, bitmapData: bitmapData};
        } else {
            null;
        }
    }
}