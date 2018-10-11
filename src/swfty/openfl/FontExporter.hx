package swfty.openfl;

import swfty.Exporter;

import haxe.ds.IntMap;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.text.TextFormat;
import openfl.text.TextField;

typedef Character = {
    id: Int,
    bitmap: Int,
    x: Int,
    y: Int, 
    width: Int, 
    height: Int, 
    ty: Float, 
    tx: Float
}

typedef FontTilemap = {
    characters: Array<Character>,
    bitmapData: BitmapData
}

class FontExporter {

    public static function export(font:String, size:Float = 24, bold:Bool = false, italic:Bool = false, ?charSet:CharSet, getId:Void->Int):FontTilemap {

        if (charSet == null) charSet = ISO_8859_1;

        var characters = [];
        var textField = new TextField();
        var textFormat = new TextFormat(font, Std.int(size), 0xFFFFFF, bold, italic);

        textField.defaultTextFormat = textFormat;

        var bitmaps = new IntMap<BitmapData>();
        var definitions = [];
        var text:String = charSet;

        // One char at a time, we could do one screenshot of all chars, would that be faster?
        for (i in 0...text.length) {
            var char = text.charAt(i);
            var code = text.charCodeAt(i);
            textField.text = char;

            var bounds = textField.getCharBoundaries(0);

            if (Math.ceil(bounds.width) > 0 && Math.ceil(bounds.height) > 0) {
                var bmpd = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0x00000000);
                
                var m = new Matrix();
                m.tx = -bounds.x;
                m.ty = -bounds.y;
                
                bmpd.draw(textField, m);

                bitmaps.set(code, bmpd);

                definitions.push({
                    id: code,
                    bitmap: getId(),
                    x: 0, y: 0, width: 0, height: 0,
                    tx: bounds.x, ty: bounds.y
                });
            }
        }

        // Transform to a Tilemap, this way we can easily replace the region for other language
        var tilemap = TilemapExporter.pack([for (definition in definitions) bitmaps.get(definition.id)]);
        for (i in 0...tilemap.tiles.length) {
            var definition = definitions[i];
            var tile = tilemap.tiles[i];

            definition.x = tile.x;
            definition.y = tile.y;
            definition.width = tile.width;
            definition.height = tile.height;

            characters.push(definition);
        }

        return {
            characters: characters,
            bitmapData: tilemap.bitmapData
        }
    }
}