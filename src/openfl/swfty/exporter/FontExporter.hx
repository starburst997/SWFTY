package openfl.swfty.exporter;

import haxe.Utf8;

import swfty.exporter.Exporter;

import haxe.ds.IntMap;

import openfl.filters.BitmapFilter;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.Font;
import openfl.utils.ByteArray;

@:access(openfl.geom.Rectangle)

typedef Character = {
    id: Int,
    bitmap: Int,
    x: Int,
    y: Int, 
    width: Int, 
    height: Int, 
    ty: Float, 
    tx: Float,
    advance: Float,
    charHeight: Float
}

typedef FontTilemap = {
    characters: Array<Character>,
    bitmapData: BitmapData
}

typedef FontGlyphs = {
    bitmaps: IntMap<BitmapData>,
    definitions: Array<Character>
}

typedef FontCache = {
    id: Int,
    font: String,
    hash: String,
    isNumeric: Bool,
    color: Int,
    filters: Array<BitmapFilter>
}

@:access(openfl.text.Font)
class FontExporter {

    public static var path = 'ref/fonts/';

    public static function exportGlyphs(font:String, size:Float = 24, bold:Bool = false, italic:Bool = false, ?charSet:Array<Int>, ?cache:FontCache, getId:Void->Int):FontGlyphs {

        if (charSet == null) charSet = CharSet.ISO_8859_1;
        if (cache != null && cache.isNumeric) charSet = CharSet.NUMERIC; 

        #if sys
        // Command line tools need the path to TTF
        //font = font.replace('-', ' ');
        var f = Font.fromFile('$path$font.ttf'); // System.getPath('$path/$font.ttf'));
        if (f != null) {
            Font.__registeredFonts.push(f);
            Font.__fontByName[f.fontName] = f;
            font = f.fontName;
        } else {
            Log.warn('Missing font: $path$font.ttf');
        }
        #end

        // TODO: Use embedded font from SWF instead? Draw each glyph...

        var textField = new TextField();
        var textFormat = new TextFormat(font, Std.int(size), cache != null ? cache.color : 0xFFFFFF, bold, italic);

        textField.defaultTextFormat = textFormat;

        if (cache != null) {
            textField.filters = cache.filters;
        }

        var bitmaps = new IntMap<BitmapData>();
        var definitions = [];
        var text = charSet;

        // One char at a time, we could do one screenshot of all chars, would that be faster?
        // Also Lime Font has all the tool already, but meh not the slowest part of the export, low priority to optimize
        for (i in 0...text.length) {
            var code = text[i];
            
            var utf8 = new Utf8();
            utf8.addChar(code);

            var char = utf8.toString();
            textField.text = char;

            var bounds = textField.getCharBoundaries(0);
            if (bounds == null) bounds = new Rectangle(0, 0, 1, 1);

            if (Math.ceil(bounds.width) > 0 && Math.ceil(bounds.height) > 0) {

                var padding = 40;
                var bmpd = new BitmapData(Math.ceil(bounds.width) + padding * 2, Math.ceil(bounds.height) + padding * 2, true, 0x00000000);
                
                var m = new Matrix();
                m.tx = -bounds.x + padding;
                m.ty = -bounds.y + padding;
                
                bmpd.draw(textField, m);

                var trimmed = TilemapExporter.trim(bmpd);
                bitmaps.set(code, trimmed.bmpd);

                #if sys
                // Not sure where this comes from...
                trimmed.rect.y -= size / 5;
                #end

                definitions.push({
                    id: code,
                    bitmap: getId(),
                    x: 0, y: 0, width: 0, height: 0,
                    tx: bounds.x + trimmed.rect.x - padding, ty: bounds.y + trimmed.rect.y - padding,
                    advance: bounds.width,
                    charHeight: bounds.height
                });
            }
        }

        return {
            definitions: definitions,
            bitmaps: bitmaps
        }
    }

    public static function exportTilemap(font:String, size:Float = 24, bold:Bool = false, italic:Bool = false, ?charSet:Array<Int>, ?cache:FontCache, getId:Void->Int):FontTilemap {
        
        var characters = [];
        var glyphs = exportGlyphs(font, size, bold, italic, charSet, cache, getId);
        
        // Transform to a Tilemap, this way we can easily replace the region for other language
        var tilemap = TilemapExporter.pack([for (definition in glyphs.definitions) glyphs.bitmaps.get(definition.id)], false);
        for (i in 0...tilemap.tiles.length) {
            var definition = glyphs.definitions[i];
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