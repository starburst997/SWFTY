package openfl.swfty.exporter;

import swfty.exporter.Exporter.CharSet;

import openfl.swfty.exporter.Shape;
import openfl.swfty.exporter.MovieClip;
import openfl.swfty.exporter.FontExporter;
import openfl.swfty.exporter.TilemapExporter;
import openfl.swfty.exporter.ClassExporter;

import zip.ZipWriter;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.crypto.Base64;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Option;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

import openfl.filters.*;
import openfl.display.PNGEncoderOptions;
import openfl.display.JPEGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

import lime.graphics.Image;
import lime.graphics.ImageChannel;
import lime.math.Vector2;

import format.png.Data;
import format.png.Writer;

import format.swf.data.filters.Filter;
import format.swf.timeline.FrameObject;
import format.swf.exporters.ShapeBitmapExporter;
import format.swf.exporters.ShapeCommandExporter;
import format.swf.data.consts.BitmapFormat;
import format.swf.data.SWFSymbol;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsJPEG2;
import format.swf.tags.TagDefineBitsJPEG3;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton;
import format.swf.tags.TagDefineButton2;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineFont2;
import format.swf.tags.TagDefineFont4;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.tags.TagSymbolClass;
import format.swf.tags.TagDefineSound;
import format.swf.SWFRoot;
import format.swf.SWFTimelineContainer;
import format.SWF;

class Exporter {

    // TODO: Default to false, mainly only for openfl before 6.0
    public static var BAKE_COLOR = true;

    static inline var MAX_STACK = 100;

    public static var tempFolder = 'temp';

    public static var logs = '';

    var maxId:Int = -1;

    var reservedTile:Int = -1;

    public var name:String;
    var definitions:IntMap<Bool>;
    
    var movieClipsOrder:Array<MovieClipDefinition>;

    var movieClips:IntMap<MovieClipDefinition>;
    var shapes:IntMap<Array<ShapeDefinition>>;
    var bitmapToShapes:IntMap<Array<ShapeDefinition>>;
    var texts:IntMap<TextDefinition>;
    var fonts:IntMap<FontDefinition>;
    
    var fontCacheId:StringMap<Int>;
    var fontCache:IntMap<FontCache>;

    var processShapes:IntMap<{tag: TagDefineShape, definition: ShapeDefinition}>;
    var processShapesId = 0;

    var bitmaps:IntMap<BitmapDefinition>;
    var bitmapKeeps:IntMap<Bool>;
    public var bitmapDatas:IntMap<BitmapData>;

    var swf:SWF;
    var data:SWFRoot;

    var alphaPalette:Bytes;

    var tilemap:Option<TilePack> = None;

    var fontTilemaps:IntMap<FontTilemap>;

    var processFrame = 0;
    var nextFrames:Array<Void->Void> = [];

    var bakedId:StringMap<Int>;

    var config:Config = {};
    var custom:CustomConfig = { name: 'NoName' };

    public static function addLog(log:String) {
        logs += '\n$log';
    }

    public static function getConfig(?config:Config):Config {
        if (config == null) config = {};

        if (config.watch == null) config.watch = false;
        if (config.watchFolder == null) config.watchFolder = 'res';
        if (config.outputFolder == null) config.outputFolder = config.watchFolder;
        if (config.fontFolder == null) config.fontFolder = FontExporter.path;
        if (config.abstractFolder == null) config.abstractFolder = 'src/swfty';
        if (config.templateFolder == null) config.templateFolder = '';
        if (config.tempFolder == null) config.tempFolder = 'temp';
        if (config.quality == null) config.quality = [];
        if (config.bakeColor == null) config.bakeColor = true;
        if (config.pngquant == null) config.pngquant = true;
        if (config.jpegtran == null) config.jpegtran = true;
        if (config.fontEnabled == null) config.fontEnabled = true;
        if (config.sharedFonts == null) config.sharedFonts = false;
        if (config.maxDimension == null) config.maxDimension = null;
        if (config.files == null) config.files = [];
        if (config.useJPEG == null) config.useJPEG = false;
        if (config.jpegQuality == null) config.jpegQuality = 90;

        // TODO: Hack, fix that
        Exporter.BAKE_COLOR = config.bakeColor;

        return config;
    }

    public static function create(bytes:ByteArray, ?config:Config, ?name:String, ?onComplete:Exporter->Void, ?onError:Dynamic->Void) {
        return new Exporter(bytes, config, name, onComplete, onError);
    }

    public function new(bytes:ByteArray, ?config:Config, ?name:String, ?onComplete:Exporter->Void, ?onError:Dynamic->Void) {
        // Check if file is valid (43 57 53)
        bytes.position = 0;
        var p = bytes.length > 0 ? bytes.readByte() : 0;
        if (bytes.length < 3 || (p != 0x43 && p != 0x46) || bytes.readByte() != 0x57 || bytes.readByte() != 0x53) {
            if (onError != null) onError('Invalid format');
            return;
        }

        this.config = getConfig(config);

        bytes.position = 0;

        swf = new SWF(bytes);
        data = swf.data;

        this.name = name == null ? 'NoName' : name;

        var custom:CustomConfig = { name: '${name}.swf' };
        for (file in config.files) {
            if (file.name == custom.name) {
                custom = file;
                break;
            }
        }

        if (custom.line == null) custom.line = this.config.line;
        this.custom = custom;

        trace('Exporting', this.name);

        movieClipsOrder = [];

        definitions = new IntMap();
        
        movieClips = new IntMap();
        shapes = new IntMap();
        texts = new IntMap();
        fonts = new IntMap();
        bitmaps = new IntMap();
        bitmapDatas = new IntMap();
        bitmapToShapes = new IntMap();
        bakedId = new StringMap();
        fontCacheId = new StringMap();
        fontCache = new IntMap();

        bitmapKeeps = new IntMap();
        processShapes = new IntMap();

        fontTilemaps = new IntMap();

        #if openfl_jd
        BitmapData.premultipliedDefault = true;
        #end

        // TODO: Remove listener
        openfl.Lib.current.addEventListener(Event.ENTER_FRAME, function(_) {
            var handlers = [for (f in nextFrames) f];
            processFrame = 0;
            nextFrames = [];

            for (f in handlers) f();
        });

        // TODO: Process root?

        var process = function f(i) { // TODO: VSCode is choking on `function process(i)`, wasn't the case before
            var tag = data.tags[i];

            function complete() {
                if (i + 1 < data.tags.length) {
                    // Process 250 tags per frame to prevent maximum call stack size
                    if (processFrame++ < MAX_STACK) {
                        f(i + 1);
                    } else {
                        nextFrames.push(function() f(i + 1));
                    }
                } else {
                    // TODO: This could be moved to addShape...
                    for (id in processShapes.keys()) {
                        var val = processShapes.get(id);
                        var tag = val.tag;
                        var shape = new Shape(this, data, tag);

                        var bounds = shape.getBounds(shape);
                        val.definition.tx = bounds.x;
                        val.definition.ty = bounds.y;

                        var bitmapData = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0x00000000);
                        
                        var m = new Matrix();
                        m.tx = -bounds.x;
                        m.ty = -bounds.y;
                        
                        bitmapData.draw(shape, m, null, null, null, true);

                        var definition:BitmapDefinition = {
                            id: id,
                            x: 0,
                            y: 0,
                            width: bitmapData.width,
                            height: bitmapData.height,
                            originalWidth: bounds.width,
                            originalHeight: bounds.height
                        };

                        bitmaps.set(id, definition);
                        bitmapDatas.set(id, bitmapData);
                        bitmapKeeps.set(id, true);

                        if (id > maxId) maxId = id;
                    }

                    // Process fonts by snapshoting the biggest size
                    for (text in texts) {
                        var font = fonts.get(text.font);
                        if (font != null && text.size > font.size) {
                            font.size = text.size;
                        }
                    }

                    for (font in fonts) {
                        #if packFont

                        // All glyphs are grouped together
                        var fontTilemap = FontExporter.exportTilemap(#if html5 font.cleanName #else font.name #end, font.size, font.bold, font.italic, fontCache.get(font.id), function() return ++maxId);
                        
                        var id = ++maxId;
                        var definition:BitmapDefinition = {
                            id: id,
                            x: 0,
                            y: 0,
                            width: fontTilemap.bitmapData.width,
                            height: fontTilemap.bitmapData.height
                        };

                        bitmaps.set(id, definition);
                        bitmapDatas.set(id, fontTilemap.bitmapData);
                        bitmapKeeps.set(id, true);

                        font.bitmap = id;
                        font.characters = fontTilemap.characters.map(function(char) return {
                            id: char.id,
                            bitmap: char.bitmap,
                            tx: char.tx,
                            ty: char.ty,
                            advance: char.advance
                        });

                        fontTilemaps.set(id, fontTilemap);
                        #else

                        // Glyphs are scattered all around the Tilemap
                        var fontGlyphs = FontExporter.exportGlyphs(#if html5 font.cleanName #else font.name #end, font.size, font.bold, font.italic, fontCache.get(font.id), function() return ++maxId);

                        var definitions = fontGlyphs.definitions;
                        var bitmaps = fontGlyphs.bitmaps;

                        for (glyph in fontGlyphs.definitions) {
                            var bitmapData = bitmaps.get(glyph.id);

                            var id = glyph.bitmap;
                            var definition:BitmapDefinition = {
                                id: id,
                                x: 0,
                                y: 0,
                                width: bitmapData.width,
                                height: bitmapData.height,
                                originalWidth: bitmapData.width,
                                originalHeight: bitmapData.height
                            };

                            this.bitmaps.set(id, definition);
                            this.bitmapDatas.set(id, bitmapData);
                            this.bitmapKeeps.set(id, true);
                        }

                        font.bitmap = -1;
                        font.characters = fontGlyphs.definitions.map(function(char) return {
                            id: char.id,
                            bitmap: char.bitmap,
                            tx: char.tx,
                            ty: char.ty,
                            advance: char.advance,
                            height: char.charHeight
                        });
                        #end
                    }

                    if (onComplete != null) onComplete(this);
                }
            }

            if (Std.is(tag, TagSymbolClass)) {
                var symbols = cast (tag, TagSymbolClass).symbols;
    
                //trace('TAG: ${tag.name} ${tag.toString()}');
                
                function process2(j) {
                    var symbol = symbols[j];
                    processSymbol(symbol, function() {
                        if (j + 1 < symbols.length) {
                            if (processFrame++ < MAX_STACK) {
                                process2(j + 1);
                            } else {
                                nextFrames.push(function() process2(j + 1));
                            }
                        } else complete();                        
                    });
                }

                if (symbols.length > 0) process2(0) else complete();
            } else {
                complete();
            }
        }
        if (data.tags.length > 0) {
            process(0);
        } else {
            if (onComplete != null) onComplete(this);
        }
    }

    function getFontCache(text:TextDefinition, filterHash:String) {
        var font = if (fonts.exists(text.font)) {
            fonts.get(text.font).name;
        } else {
            '';
        }
        
        var hash = '${font}-${BAKE_COLOR ? text.color : 0xFFFFFF}-${filterHash}';

        // Create first cache
        if (!fontCache.exists(text.font)) {
            var cache = {
                id: text.font,
                font: font,
                hash: hash,
                isNumeric: isNumeric(text.text),
                color: text.color,
                filters: []
            };

            fontCache.set(text.font, cache);
            fontCacheId.set(hash, text.font);
        }
        
        // If cache doesn'T exists
        if (!fontCacheId.exists(hash)) {
            var id = --processShapesId;
            var cache = {
                id: id,
                font: font,
                hash: hash,
                isNumeric: isNumeric(text.text),
                color: text.color,
                filters: []
            };

            fontCacheId.set(hash, id);
            fontCache.set(id, cache);

            // Duplicate font
            if (fonts.exists(text.font)) {
                var font = fonts.get(text.font);

                var dupe = {
                    id: id,
                    name: font.name,
                    cleanName: font.cleanName,
                    color: font.color,
                    size: font.size,
                    bold: font.bold,
                    italic: font.italic,
                    bitmap: font.bitmap,
                    ascent: font.ascent,
                    descent: font.descent,
                    leading: font.leading,
                    characters: [for (char in font.characters) char]
                };

                fonts.set(id, dupe);
            }
        }

        var cache = fontCache.get(fontCacheId.get(hash));

        text.font = cache.id;
        if (cache.isNumeric) cache.isNumeric = isNumeric(text.text);
        
        return cache;
    }

    function isNumeric(str:String) {
        var n = 0;
        for (i in 0...str.length) {
            if (CharSet.NUMERIC.indexOf(haxe.Utf8.charCodeAt(str, i)) == -1) return false;
            if (haxe.Utf8.charCodeAt(str, i) != 45) n++; // But not only "-"
        }

        return true && (n > 0);
    }

    public function getTilemap(?width:Int, ?height:Int, scale = 1.0, cache = true, forceDimension = false) {
        return switch(tilemap) {
            case Some(tilemap) if (cache) : tilemap;
            case _ : 

                if (width == null) width = config.maxDimension.width;
                if (height == null) height = config.maxDimension.height;

                // Create Tilemap based on all bitmapDatas
                var keys = [for (key in bitmapDatas.keys()) key];
                var bmpds = keys.map(function(key) return bitmapKeeps.exists(key) ? bitmapDatas.get(key) : null);

                // Remove all duplicates
                // TODO: !!!

                // Process all bitmaps and figure out the max scale
                // TODO: For "real" shapes, we might want to do that before doing the screenshot
                for (key in keys) if (bitmapKeeps.exists(key)) {
                    var bitmap = bitmaps.get(key);

                    //trace(bitmap.id);
                }

                // Trim, then back to power of 2
                var tilemap = TilemapExporter.fit(bmpds, width, height, scale, true, forceDimension);
                var w = 1, h = 1;
                while((w *= 2) < tilemap.bitmapData.width) {}
                while((h *= 2) < tilemap.bitmapData.height) {}

                var bitmapData = if (tilemap.bitmapData.width == w && tilemap.bitmapData.height == h) {
                    tilemap.bitmapData;
                } else {
                    var bmpd = new BitmapData(w, h, true, 0x00000000);
                    bmpd.copyPixels(tilemap.bitmapData, tilemap.bitmapData.rect, new Point(0, 0));
                    bmpd;
                }
                tilemap.bitmapData = bitmapData;

                // We're done, so go back to default
                #if openfl_jd
                BitmapData.premultipliedDefault = true;
                #end

                trace('Tilemap is ${tilemap.bitmapData.width}x${tilemap.bitmapData.height}');

                for (i in 0...keys.length) {
                    var key = keys[i];

                    var bitmap = bitmaps.get(key);
                    var tile = tilemap.tiles[i];
                    
                    if (tile != null) {
                        bitmap.x = tile.x;
                        bitmap.y = tile.y;
                        bitmap.width = tile.width;
                        bitmap.height = tile.height;
                    }
                }

                for (key in fontTilemaps.keys()) {
                    var font = fontTilemaps.get(key);
                    var fontTile = bitmaps.get(key);
                    font.characters.iter(function(char) {
                        var tile:BitmapDefinition = {
                            id: char.bitmap,
                            x: fontTile.x + char.x,
                            y: fontTile.y + char.y,
                            width: char.width,
                            height: char.height,
                            originalWidth: char.width,
                            originalHeight: char.height
                        };

                        bitmaps.set(char.bitmap, tile);
                        tilemap.tiles.push(tile);
                    });
                }

                this.tilemap = Some(tilemap);
                tilemap;
        }
    }

    public function getJSON() {
        return haxe.Json.stringify(getSWFTYJson());
    }

    function getSWFTYJson():SWFTYJson {
        return {
            tilemap: switch(tilemap) {
                case Some(tilemap) : {
                    width: tilemap.bitmapData.width,
                    height: tilemap.bitmapData.height,
                    reserved: reservedTile,
                    scale: tilemap.scale
                }
                case None : {
                    width: 0,
                    height: 0,
                    reserved: -1,
                    scale: 1.0
                }
            },
            name: name,
            definitions: movieClipsOrder,
            tiles: [for (bmp in bitmaps) bmp],
            fonts: [for (font in fonts) font]
        }
    }

    public function getBinary() {
        // TODO: Should use class all along instead of struct, but really a minor optimisation issue, will do for now
        var swfty = SWFTYType.fromJson(getSWFTYJson());
        return hxbit.Serializer.save(swfty);
    }

    public function getPNG(bmpd:BitmapData) {
        var png = bmpd.encode(bmpd.rect, new PNGEncoderOptions());
        
        #if sys
        // Save file to disk, run pngquant, save to zip 
        if (config.pngquant) {
            var temp1 = '${config.tempFolder}/temp${Std.int(Math.random() * 0xFFFFFF)}.png';
            var temp2 = '${config.tempFolder}/temp${Std.int(Math.random() * 0xFFFFFF)}.png';
            
            if (!FileSystem.exists(config.tempFolder)) FileSystem.createDirectory(config.tempFolder);
            File.saveBytes(temp1, png);

            Sys.command('imagemin --plugin=pngquant $temp1 > $temp2');

            if (FileSystem.exists(temp2)) {
                png = File.getBytes(temp2);
                FileSystem.deleteFile(temp2);
            } else {
                trace('Error: pngquant did not run successfully!');
            }

            try {
                FileSystem.deleteFile(temp1);
                //FileSystem.deleteDirectory(config.tempFolder);
            } catch(e:Dynamic) {
                // Might be some leftovers or the directory already existed...
            }
        }
        #end

        return png;
    }

    public function getJPG(bmpd:BitmapData):{
        jpg: Bytes,
        alpha: Bytes
    } {
        // Extract alpha channel
        var alpha = new BitmapData(bmpd.width, bmpd.height, false, 0x000000);

        // TODO: Could it be more efficient to only use one channel?
        alpha.copyChannel(bmpd, bmpd.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
        //alpha.copyChannel(bmpd, bmpd.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
        //alpha.copyChannel(bmpd, bmpd.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);

        var jpg = bmpd.encode(bmpd.rect, new JPEGEncoderOptions(config.jpegQuality));

        #if sys
        if (config.jpegtran) {
            var temp1 = '${config.tempFolder}/temp${Std.int(Math.random() * 0xFFFFFF)}.jpg';
            var temp2 = '${config.tempFolder}/temp${Std.int(Math.random() * 0xFFFFFF)}.jpg';
            
            if (!FileSystem.exists(config.tempFolder)) FileSystem.createDirectory(config.tempFolder);
            File.saveBytes(temp1, jpg);

            Sys.command('imagemin --plugin=jpegtran $temp1 > $temp2');

            if (FileSystem.exists(temp2)) {
                jpg = File.getBytes(temp2);
                FileSystem.deleteFile(temp2);
            } else {
                trace('Error: mozjpeg did not run successfully!');
            }

            try {
                FileSystem.deleteFile(temp1);
                //FileSystem.deleteDirectory(config.tempFolder);
            } catch(e:Dynamic) {
                // Might be some leftovers or the directory already existed...
            }
        }
        #end

        return {
            jpg: jpg,
            alpha: getPNG(alpha)
        }
    }

    public function getQualities():Array<InnerQuality> {
        var results = [{
            name: 'original',
            appendName: false,
            outputFolder: config.outputFolder,
            scale: 1.0,
            maxDimension: config.maxDimension
        }];

        for (q in config.quality) {
            results.push(q);
        }
        
        return results;
    }

    public function getMaxDimension(originalMaxWidth:Int, originalMaxHeight:Int, normalWidth:Int, normalHeight:Int, qualityMaxWidth:Int, qualityMaxHeight:Int) {
        var scaleW = originalMaxWidth / qualityMaxWidth;
        var scaleH = originalMaxHeight / qualityMaxHeight;

        return {
            width: Std.int(normalWidth / scaleW),
            height: Std.int(normalHeight / scaleH)
        }
    }

    // The whole point of this library was so I could get to name this function
    public function getSwfty(useJson = false, compressed = true, ?width:Int, ?height:Int, ?scale = 1.0, ?forceDimension = false) {
        if (width == null) width = config.maxDimension.width;
        if (height == null) height = config.maxDimension.height;
        
        var custom:CustomConfig = { name: '${name}.swf' };
        for (file in config.files) {
            if (file.name == custom.name) {
                custom = file;
                break;
            }
        }

        if (custom.reservedSpace != null && (reservedTile == -1)) {
            var id = ++maxId;
            var definition:BitmapDefinition = {
                id: id,
                x: 0,
                y: 0,
                width: custom.reservedSpace.width,
                height: custom.reservedSpace.height,
                originalWidth: custom.reservedSpace.width,
                originalHeight: custom.reservedSpace.height
            };

            bitmaps.set(id, definition);
            bitmapDatas.set(id, new BitmapData(definition.width, definition.height, true, 0x00000000));
            bitmapKeeps.set(id, true);

            reservedTile = id;
        }

        var tilemap = getTilemap(width, height, scale, false, forceDimension);

        Exporter.addLog('Tilemap: ${tilemap.bitmapData.width}x${tilemap.bitmapData.height} (${tilemap.scale})');

        var zip = new ZipWriter();

        if (config.useJPEG) {
            var jpg = getJPG(tilemap.bitmapData);
            zip.addBytes(jpg.jpg, 'tilemap.jpg', false);
            zip.addBytes(jpg.alpha, 'alpha.png', false);
        } else {
            var png = getPNG(tilemap.bitmapData);
            zip.addBytes(png, 'tilemap.png', false);
        }
        
        if (useJson) {
            zip.addString(getJSON(), 'definitions.json', compressed);
        } else {
            zip.addBytes(getBinary(), 'definitions.bin', compressed);
        }

        return zip.finalize();
    }

    public function getTilemapInfo() {
        var tilemap = getTilemap();
        var png = getPNG(tilemap.bitmapData);
        return {
            src: 'data:image/png;base64,' + Base64.encode(png),
            width: tilemap.bitmapData.width,
            height: tilemap.bitmapData.height,
            size: png.length
        };
    }

    public function getAllNames() {
        var cache:IntMap<Int> = new IntMap();
        
        var countChildren = function f(mc:MovieClipDefinition) {
            if (mc == null) return 0;
            
            if (cache.exists(mc.id)) {
                return cache.get(mc.id);
            }
            
            var innerCount = 0;
            for (child in mc.children) {
                if (cache.exists(child.id)) {
                    innerCount += cache.get(child.id);
                } else {
                    innerCount += f(movieClips.get(child.id));
                }
                
                innerCount++;
            }

            cache.set(mc.id, innerCount);

            return innerCount;
        }
        
        return movieClipsOrder
            .filter(function(i) return !i.name.empty())
            .sortdf(function(i) return countChildren(i))
            .map(function(i) return i.name);
    }

    // This gives us optional compile-time swfty to our safety
    public function getAbstracts(?template:String = '') {
        var swfty = SWFTYType.fromJson(getSWFTYJson());

        var i = name.lastIndexOf('/');
        if (i == -1) i = name.lastIndexOf('\\');

        var abstractName = i == -1 ? name : name.substr(i + 1);
        return ClassExporter.export(swfty, abstractName, name.replace(abstractName, '').replace('/', '.').replace('\\', '.'), '', template);
    }

    public function getRootAbstract(?quality:StringMap<String>, ?files:Array<FileTemplate>, ?template:String = '') {
        return ClassExporter.exportRoot(quality, files, template);
    }

    function getTransform(matrix:Matrix):Transform {
        return {
            a: matrix.a,
            b: matrix.b,
            c: matrix.c,
            d: matrix.d,
            tx: matrix.tx,
            ty: matrix.ty
        }
    }

    function addSprite(tag:SWFTimelineContainer, root:Bool = false, ?_onComplete:Void->Void):MovieClipDefinition {
        
        var id:Int = if (Std.is(tag, IDefinitionTag)) {
			untyped tag.characterId;
		} else {
            -1;
        };

        var children:Array<SpriteDefinition> = [];
        var definition:MovieClipDefinition = {
            id: id,
            name: '',
            children: children
        };

        movieClips.set(id, definition);

        function onComplete() {
            movieClipsOrder.push(definition);
            _onComplete();
        }

        function process(i) {
            var frameData = tag.frames[i];
            var objects = frameData.getObjectsSortedByDepth();

            var mask:FrameObject = null;
            var maskDepth = 0;
            var isMask = false;

            function process2(j) {
                var object = objects[j];
                var childTag = cast data.getCharacter(object.characterId);
                
                if (mask != null && mask.clipDepth < object.depth) {
                    mask = null;
                }

                isMask = false;
                if (object.clipDepth != 0 #if (neko || html5) && object.clipDepth != null #end) {
                    // TODO: Eventually I would like to embed the mask as a simple "rect" instead, but having it as a Sprite also have it's advantages...
                    mask = object;
                    isMask = true;

                    trace('Found mask: ${mask.clipDepth}');
                }

                processTag(childTag, function() {
                    var placeTag:TagPlaceObject = cast tag.tags[object.placedAtIndex];

                    var characterId = object.characterId;
                    var matrix = if (placeTag.matrix != null) {
                        var matrix = placeTag.matrix.matrix;
                        matrix.tx *= (1 / 20.0);
                        matrix.ty *= (1 / 20.0);
                        matrix;
                    } else {
                        new Matrix();
                    }

                    var alpha = if (placeTag.colorTransform != null) {
                        // TODO: More than just "alpha" multiplier
                        placeTag.colorTransform.colorTransform.alphaMultiplier;
                    } else {
                        1.0;
                    }

                    var blendMode:BlendMode = Normal;
                    if (placeTag.hasBlendMode) {
                        blendMode = format.swf.data.consts.BlendMode.toString(placeTag.blendMode);
                    }

                    var hasColor =
                        placeTag.colorTransform != null && 
                        (placeTag.colorTransform.rMult != 256.0 || 
                        placeTag.colorTransform.gMult != 256.0 || 
                        placeTag.colorTransform.bMult != 256.0 || 
                        placeTag.colorTransform.rAdd != 0 || 
                        placeTag.colorTransform.gAdd != 0 || 
                        placeTag.colorTransform.bAdd != 0);

                    var filterHash = !placeTag.hasFilterList ? '' : {
                        var str = '';
                        for (surfaceFilter in placeTag.surfaceFilterList) {
                            var type = surfaceFilter.type;
                            switch (type) {
                                case BlurFilter (blurX, blurY, quality):
                                    str += 'BlurFilter($blurX, $blurY, $quality)';
                                
                                case ColorMatrixFilter (matrix):
                                    str += 'ColorMatrixFilter($matrix)';
                                
                                case DropShadowFilter (distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject):
                                    str += 'DropShadowFilter($distance, $angle, $color, $alpha, $blurX, $blurY, $strength, $quality, $inner, $knockout, $hideObject)';
                                
                                case GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout):
                                    if (custom.line != null) {
                                        str += 'GlowFilter(${custom.line.color}, ${custom.line.alpha}, ${custom.line.blurX}, ${custom.line.blurY}, ${custom.line.strength})';//, $quality, $inner, $knockout)';   
                                    } else {
                                        str += 'GlowFilter($color, $alpha, $blurX, $blurY, $strength)';//, $quality, $inner, $knockout)';   
                                    }
                            }
                        }
                        str;
                    }

                    if (placeTag.hasFilterList || (placeTag.hasCacheAsBitmap && placeTag.bitmapCache != 0) || (BAKE_COLOR && hasColor) /*|| placeTag.hasBlendMode*/) {
                        // Basically like cacheAsBitmap, take a screenshot of the MovieClip
                        // also bake filters on texts (aka outlines done with GlowFilter)

                        var colorHash = !hasColor ? '' : {
                            var c = placeTag.colorTransform;
                            '${c.rMult},${c.gMult},${c.bMult},${c.rAdd},${c.gAdd},${c.bAdd}';
                        };

                        // TODO: OpenFL doesn't support inner / knockout !!
                        var filters:Array<BitmapFilter> = [];
                        if (placeTag.hasFilterList) {
                            for (surfaceFilter in placeTag.surfaceFilterList) {
                                var type = surfaceFilter.type;
                                if (type != null) {
                                    switch (type) {
                                        case BlurFilter (blurX, blurY, quality):
                                            filters.push (new BlurFilter (blurX, blurY, quality));
                                        
                                        case ColorMatrixFilter (matrix):
                                            filters.push (new ColorMatrixFilter (matrix));
                                        
                                        case DropShadowFilter (distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject):
                                            if (inner || knockout) Log.warn('Inner / Knockout is not supported');
                                            filters.push (new DropShadowFilter (distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject));
                                        
                                        case GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout):
                                            if (inner || knockout) Log.warn('Inner / Knockout is not supported');
                                            if (custom.line != null) {
                                                filters.push (new GlowFilter (custom.line.color, custom.line.alpha, custom.line.blurX, custom.line.blurY, custom.line.strength, quality, inner, knockout));
                                            } else {
                                                filters.push (new GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout));
                                            }   
                                    }
                                }
                            }
                        }

                        if (Std.is(childTag, TagDefineSprite)) {

                            var hash = '${childTag.characterId}-$filterHash-$colorHash';

                            if (bakedId.exists(hash)) {

                                trace('*********** HAS HASH !!!!!!!!!!!!!');
                                characterId = bakedId.get(hash);

                            } else {

                                var movieClip = new MovieClip(this, cast childTag);

                                movieClip.filters = filters;

                                if (hasColor) {
                                    var c = placeTag.colorTransform;
                                    movieClip.transform.colorTransform = new openfl.geom.ColorTransform(c.rMult / 255.0, c.gMult / 255.0, c.bMult / 255.0, 1.0, c.rAdd, c.gAdd, c.bAdd, 0.0);
                                }

                                // We're essentially creating a unique baked copy with all filters / blendMode applied to it
                                characterId = --processShapesId;

                                var id = --processShapesId;
                                var shape:ShapeDefinition = {
                                    id: 0,
                                    bitmap: id,
                                    a: 1.0,
                                    b: 0.0,
                                    c: 0.0,
                                    d: 1.0,
                                    tx: 0.0,
                                    ty: 0.0
                                };

                                var bounds = movieClip.getBounds(movieClip);
                                shape.tx = bounds.x;
                                shape.ty = bounds.y;

                                // TODO: Maybe add this as settings...
                                var padding = 40;

                                var bitmapData = new BitmapData(Math.ceil(bounds.width) + padding * 2, Math.ceil(bounds.height) + padding * 2, true, 0x00000000);

                                var m = new Matrix();
                                m.tx = -bounds.x + padding;
                                m.ty = -bounds.y + padding;
                                
                                bitmapData.draw(movieClip, m, movieClip.transform.colorTransform, null, null, true);

                                var trimmed = TilemapExporter.trim(bitmapData);

                                shape.tx = bounds.x + trimmed.rect.x - padding;
                                shape.ty = bounds.y + trimmed.rect.y - padding;

                                var definition:BitmapDefinition = {
                                    id: id,
                                    x: 0,
                                    y: 0,
                                    width: trimmed.bmpd.width,
                                    height: trimmed.bmpd.height,
                                    originalWidth: bounds.width,
                                    originalHeight: bounds.height
                                };

                                bitmaps.set(id, definition);
                                bitmapDatas.set(id, trimmed.bmpd);
                                bitmapKeeps.set(id, true);

                                shapes.set(characterId, [shape]);

                                bakedId.set(hash, characterId);
                            }
                        } else if (Std.is(childTag, TagDefineEditText)) {

                            if (texts.exists(characterId)) {
                                var text = texts.get(characterId);

                                var cache = getFontCache(text, filterHash);
                                cache.filters = filters;
                            }
                        }
                    }

                    var visible = if (placeTag.hasVisible) {
                        placeTag.visible != 0;
                    } else {
                        true;
                    }

                    if (mask != null && !isMask) trace('Found a masked object');

                    if (texts.exists(characterId)) {
                        var text = texts.get(characterId);

                        // Update cache
                        getFontCache(text, filterHash);
                    }

                    var transform = getTransform(matrix);
                    var definition:SpriteDefinition = {
                        id: characterId,
                        name: placeTag.instanceName,
                        a: transform.a,
                        b: transform.b,
                        c: transform.c,
                        d: transform.d,
                        tx: transform.tx,
                        ty: transform.ty,
                        color: if (hasColor && !BAKE_COLOR) {
                            r: placeTag.colorTransform.rMult,
                            g: placeTag.colorTransform.gMult,
                            b: placeTag.colorTransform.bMult,
                            rAdd: placeTag.colorTransform.rAdd,
                            gAdd: placeTag.colorTransform.gAdd,
                            bAdd: placeTag.colorTransform.bAdd,
                        } else null, 
                        blendMode: blendMode == Normal ? null : blendMode,
                        mask: mask == null || isMask ? null : maskDepth,
                        visible: !isMask && visible,
                        alpha: alpha,
                        text: texts.exists(characterId) ? texts.get(characterId) : null,
                        shapes: shapes.exists(characterId) ? shapes.get(characterId) : []
                    }

                    if (isMask) maskDepth = children.length;

                    // If the name already exists, add "_" at the end
                    if (!definition.name.empty()) {
                        for (child in children) {
                            if (child.name == definition.name) {
                                definition.name += '_';
                            }
                        }
                    }

                    children.push(definition);

                    if (j + 1 < objects.length) {
                        if (processFrame++ < MAX_STACK) {
                            process2(j + 1);
                        } else {
                            nextFrames.push(function() process2(j + 1));
                        } 
                    // TODO: Only process 1 frame for now...
                    //else if (i + 1 < tag.frames.length) process(i + 1) 
                    } else onComplete();

                    //if (j + 1 >= objects.length) onComplete();
                });
            }

            if (objects.length > 0) process2(0) else onComplete();
        }
        if (tag.frames.length > 0) process(0) else onComplete();

        return definition;
    }

    function addShape(tag:TagDefineShape, onComplete:Void->Void) {
        var handler = new ShapeCommandExporter(data);
		tag.export(handler);

        var bitmaps = ShapeBitmapExporter.process(handler);

        var shapes = [];
        this.shapes.set(tag.characterId, shapes);
    
        if (bitmaps != null) {
            var process = function f(i) {  
                var bitmap = bitmaps[i];

                processTag(cast data.getCharacter(bitmap.id), function() {
                    var transform = getTransform(bitmap.transform);
                    var definition:ShapeDefinition = {
                        id: i,
                        bitmap: bitmap.id,
                        a: transform.a,
                        b: transform.b,
                        c: transform.c,
                        d: transform.d,
                        tx: transform.tx,
                        ty: transform.ty
                    }

                    bitmapKeeps.set(bitmap.id, true);
                    shapes.push(definition);

                    if (i + 1 < bitmaps.length) {
                        if (processFrame++ < MAX_STACK) {
                            f(i + 1);
                        } else {
                            nextFrames.push(function() f(i + 1));
                        }
                    } else onComplete();
                });
            }

            if (bitmaps.length > 0) process(0) else onComplete();
        } else {

            //processShapes.push(tag);
            //onComplete();

            var sendRect = false;
            var bitmaps = [];
            var rect = new Rectangle();
            var rects = [];
            for (command in handler.commands) {
                switch(command) {
					case BeginBitmapFill(bitmapID, _, _, _):
                        bitmaps.push(command);
                        sendRect = true;
					
                    case MoveTo (x, y):
                        rect.x = x;
                        rect.y = y;
                    case LineTo (x, y):
                        if (x > rect.right) rect.right = x;
                        if (x < rect.left) rect.left = x;
                        if (y > rect.bottom) rect.bottom = y;
                        if (y < rect.top) rect.top = y;
                    case EndFill:
                        
                        if (sendRect) {
                            rects.push(rect);
                        }

                        sendRect = false;
                        rect = new Rectangle();

                    
                    default:
				}
            }

            // No bitmap, then add for screenshot processing
            if (bitmaps.length == 0) {
                var id = --processShapesId;
                var definition:ShapeDefinition = {
                    id: 0,
                    bitmap: id,
                    a: 1.0,
                    b: 0.0,
                    c: 0.0,
                    d: 1.0,
                    tx: 0.0,
                    ty: 0.0
                }

                processShapes.set(id, {tag: tag, definition: definition});
                shapes.push(definition);
            }

            var n = 0;
            var process = function f(i) {
                var command = bitmaps[i];
                var rect = rects[i];
                switch(command) {
					case BeginBitmapFill(bitmapID, matrix, repeat, smooth):
                        processTag(cast data.getCharacter(bitmapID), function() {
                            // Add tiling bitmap shapes
                            if (i < rects.length) {
                                var bmpd = bitmapDatas.get(bitmapID);
                                
                                var padding = 1.0;
                                var scaleX = MathUtils.scaleX(matrix.a, matrix.b, matrix.c, matrix.d);
                                var scaleY = MathUtils.scaleY(matrix.a, matrix.b, matrix.c, matrix.d);
                                var bmpdWidth:Float = Math.abs(Std.int(bmpd.width * scaleX)) - 1;
                                var bmpdHeight:Float = Math.abs(Std.int(bmpd.height * scaleY)) - 1;

                                // Add padding on dimension (1 pixel on each side)
                                // Fix scale based on new width
                                // Recreate Matrix with new scale
                                // Position should overlap each part
                                // Based on col / row adjust scale to fit perfectly

                                var col = Std.int(Math.max(rect.width / bmpdWidth, 1));
                                var row = Std.int(Math.max(rect.height / bmpdHeight, 1));

                                bmpdWidth = rect.width / col;
                                bmpdHeight = rect.height / row;

                                var oldScaleX = scaleX;
                                var oldScaleY = scaleY;
                                scaleX = (bmpdWidth + padding * 2) / bmpd.width;
                                scaleY = (bmpdHeight + padding * 2) / bmpd.height;

                                // Adjust with new scale
                                matrix.scale(oldScaleX / scaleX, oldScaleY / scaleY);

                                if (rect.width / bmpdWidth - col > 0.25) col++;
                                if (rect.height / bmpdHeight - row > 0.25) row++;

                                for (x in 0...col) {
                                    for (y in 0...row) {
                                        var definition:ShapeDefinition = {
                                            id: n++,
                                            bitmap: bitmapID,
                                            a: matrix.a,
                                            b: matrix.b,
                                            c: matrix.c,
                                            d: matrix.d,
                                            tx: rect.x + (scaleX > 0 ? x : x + 1) * bmpdWidth - (x == 0 ? 0 : padding),
                                            ty: rect.y + (scaleY > 0 ? y : y + 1) * bmpdHeight - (y == 0 ? 0 : padding)
                                        }

                                        shapes.push(definition);
                                    }
                                }

                                bitmapKeeps.set(bitmapID, true);
                            }
                            
                            if (i + 1 < bitmaps.length) {
                                if (processFrame++ < MAX_STACK) {
                                    f(i + 1);
                                } else {
                                    nextFrames.push(function() f(i + 1));
                                }
                            } else onComplete();
                        });
					default:
                        if (i + 1 < bitmaps.length) {
                            if (processFrame++ < MAX_STACK) {
                                f(i + 1);
                            } else {
                                nextFrames.push(function() f(i + 1));
                            }
                        } else onComplete();
				}
            }
            if (bitmaps.length > 0) process(0) else onComplete();
        }
    }

    function addBitmap(tag:IDefinitionTag, onComplete:Void->Void) {
        var bitmapData:BitmapData = null;
		
        function complete() {
            if (bitmapData != null) {
                var definition:BitmapDefinition = {
                    id: tag.characterId,
                    x: 0,
                    y: 0,
                    width: bitmapData.width,
                    height: bitmapData.height,
                    originalWidth: bitmapData.width,
                    originalHeight: bitmapData.height
                };

                bitmaps.set(tag.characterId, definition);
                bitmapDatas.set(tag.characterId, bitmapData);

                if (tag.characterId > maxId) maxId = tag.characterId;
            }

            onComplete();
        }

		if (Std.is(tag, TagDefineBitsLossless)) {
			
			var data:TagDefineBitsLossless = cast tag;

			var transparent = (data.level > 1);
			var buffer = data.zlibBitmapData;
			buffer.uncompress();
			buffer.position = 0;

			if (data.bitmapFormat == BitmapFormat.BIT_8) {
				
				var palette = Bytes.alloc(data.bitmapColorTableSize * 3);
				var alpha = null;
				
				if (transparent) alpha = Bytes.alloc(data.bitmapColorTableSize);
				var index = 0;
				
				for (i in 0...data.bitmapColorTableSize) {
					palette.set(index++, buffer.readUnsignedByte());
					palette.set(index++, buffer.readUnsignedByte());
					palette.set(index++, buffer.readUnsignedByte());
					if (transparent) alpha.set(i, buffer.readUnsignedByte());
				}
				
				var paddedWidth:Int = Math.ceil(data.bitmapWidth / 4) * 4;
				var values = Bytes.alloc((data.bitmapWidth + 1) * data.bitmapHeight);
				index = 0;
				
				for (y in 0...data.bitmapHeight) {
					values.set(index++, 0);
					values.blit(index, buffer, buffer.position, data.bitmapWidth);
					index += data.bitmapWidth;
					buffer.position += paddedWidth;
				}
				
				var png = new List();
				png.add(CHeader( { width: data.bitmapWidth, height: data.bitmapHeight, colbits: 8, color: ColIndexed, interlaced: false } ));
				png.add(CPalette(palette));
				if (transparent) png.add(CUnknown("tRNS", alpha));
				
                var bytes = zip.Zip.compress(values);
                png.add(CData(bytes));
                png.add(CEnd);
				
				var output = new BytesOutput();
				var writer = new Writer(output);
				writer.write(png);
				
                #if sync
                ({var bmpd = BitmapData.fromBytes(output.getBytes());
                #else
                BitmapData.loadFromBytes(output.getBytes()).onComplete(function(bmpd) {
                #end
                    bitmapData = bmpd;
                    complete();
                });
			} else {

				bitmapData = new BitmapData(data.bitmapWidth, data.bitmapHeight, transparent);
				
				bitmapData.image.buffer.premultiplied = false;
				bitmapData.setPixels(bitmapData.rect, buffer);
				bitmapData.image.buffer.premultiplied = true;
				bitmapData.image.premultiplied = false;
				
                complete();
			}
			
		} else if (Std.is(tag, TagDefineBitsJPEG2)) {
			
			var data:TagDefineBitsJPEG2 = cast tag;
			
			if (Std.is(tag, TagDefineBitsJPEG3)) {
				
				var alpha = cast (tag, TagDefineBitsJPEG3).bitmapAlphaData;
				alpha.uncompress();
				alpha.position = 0;
				
				if (alphaPalette == null) {
					alphaPalette = Bytes.alloc(256 * 3);
					var index = 0;
					
					for (i in 0...256) {
						alphaPalette.set(index++, i);
						alphaPalette.set(index++, i);
						alphaPalette.set(index++, i);
					}
				}
				
                #if sync
				({var image = Image.fromBytes(data.bitmapData);
                #else
                Image.loadFromBytes(data.bitmapData).onComplete(function(image) {
                #end
                    // Some legit JPEG can be "null" in newer openfl, I reverted JPEG lib version
                    if (image == null) {
                        // TODO: Used to works before upgrade to latest openfl...
                        bitmapData = new BitmapData(1, 1, true, 0x00000000);
                        complete();
                    } else {
                        var values = Bytes.alloc((image.width + 1) * image.height);
                        var index = 0;
                        
                        for (y in 0...image.height) {
                            values.set(index++, 0);
                            values.blit(index, alpha, alpha.position, image.width);
                            index += image.width;
                            alpha.position += image.width;
                        }
                        
                        var png = new List();
                        png.add(CHeader( { width: image.width, height: image.height, colbits: 8, color: ColIndexed, interlaced: false } ));
                        png.add(CPalette(alphaPalette));
                        
                        var bytes = zip.Zip.compress(values);
                        png.add(CData(bytes));
                        png.add(CEnd);
                        
                        var output = new BytesOutput();
                        var writer = new Writer(output);
                        writer.write(png);
                        
                        #if sync
                        ({var bitmapDataAlpha = BitmapData.fromBytes(output.getBytes());
                        #else
                        BitmapData.loadFromBytes(output.getBytes()).onComplete(function(bitmapDataAlpha) {
                        #end
                            var bitmapDataJPEG = BitmapData.fromImage(image);
                            bitmapData = new BitmapData(image.width, image.height, true, 0x00000000);

                            var alpha = Image.fromBitmapData(bitmapDataAlpha);
                            bitmapData.copyPixels(bitmapDataJPEG, bitmapDataJPEG.rect, new Point(0, 0));
                            
                            var jpeg = Image.fromBitmapData(bitmapData);
                            jpeg.copyChannel(alpha, alpha.rect, new Vector2(), ImageChannel.RED, ImageChannel.ALPHA);

                            jpeg.buffer.premultiplied = true;
            
                            #if !sys
                            jpeg.premultiplied = false;
                            #end
                            
                            bitmapData = BitmapData.fromImage(jpeg);
                            complete();
                        });
                    }
                });
			} else {
                #if sync
                ({var bmpd = BitmapData.fromBytes(data.bitmapData);
                #else
                BitmapData.loadFromBytes(data.bitmapData).onComplete(function(bmpd) {
                #end
                    bitmapData = bmpd;
                    complete();
                });
			}
			
		} else if (Std.is(tag, TagDefineBits)) {
			
            var data:TagDefineBits = cast tag;
            #if sync
            ({var bmpd = BitmapData.fromBytes(data.bitmapData);
            #else
            BitmapData.loadFromBytes(data.bitmapData).onComplete(function(bmpd) {
            #end
                bitmapData = bmpd;
                complete();
            });
		}
    }

    function addFont(tag:IDefinitionTag, onComplete:Void->Void) {
		
		if (Std.is(tag, TagDefineFont2)) {
			var defineFont:TagDefineFont2 = cast tag;
			
            var definition:FontDefinition = {
                id: tag.characterId,
                name: 'Arial',
                cleanName: 'Arial',
                color: 0xFFFFFF, // TODO: If we detect only one color, use that color so no colorTtransform is needed
                size: 12,
                bold: false,
                italic: false,
                ascent: 0,
                descent: 0,
                leading: 0,
                bitmap: 0,
                characters: []
            };

			//symbol.advances = cast defineFont.fontAdvanceTable.copy();
			definition.ascent = defineFont.ascent;
			definition.bold = defineFont.bold;
			definition.descent = defineFont.descent;
			definition.italic = defineFont.italic;
			definition.leading = defineFont.leading;
			definition.name = defineFont.fontName;

            // TODO: HTML5 only?
            definition.cleanName = definition.name.replace(' Bold', '').replace(' Semibold', '').replace(' Italic', '').replace('-Bold', '').replace('-Semibold', '').replace('-Italic', '');

            // Add space between lower / upper case
            var r = ~/([a-z])([A-Z])/g;
            definition.cleanName = r.replace(definition.cleanName,"$1 $2");

			fonts.set(tag.characterId, definition);
		}

        onComplete();
	}

    function addDynamicText(tag:TagDefineEditText, onComplete:Void->Void) {
		
        var definition:TextDefinition = {
            font: 0,
            align: Left,
            size: 12,
            color: 0x000000,
            text: '',
            html: '',
            multiline: false,
            leftMargin: 0,
            rightMargin: 0,
            indent: 0,
            leading: 0,
            x: 0,
            y: 0,
            width: 0,
            height: 0,
        };

		if (tag.hasTextColor) definition.color = tag.textColor;
		if (tag.hasText) definition.html = tag.initialText;

        var r = ~/<[^<]*>/g;
        definition.text = r.replace(definition.html.replace('</p>', '\n').replace('&apos;', '\'').replace('&gt;', '>').replace('&lt;', '<'), '');
        
        // Clean up if new line at the end
        if (definition.text.charAt(definition.text.length - 1) == '\n') {
            definition.text = definition.text.substr(0, definition.text.length - 1);
        }

        definition.multiline = tag.multiline;
        definition.size = tag.fontHeight / 20.0;

        if (tag.hasLayout) {
			switch (tag.align) {
				case 0: definition.align = Left;
				case 1: definition.align = Right;
				case 2: definition.align = Center;
				case 3: definition.align = Justify;
			}
			
			definition.leftMargin = tag.leftMargin;
			definition.rightMargin = tag.rightMargin;
			definition.indent = tag.indent;
			definition.leading = tag.leading;
		}

		if (tag.hasFont) {
			var font:TagDefineFont2 = cast data.getCharacter(tag.fontId);
			if (font != null) processTag(font, function() {});
			
            definition.font = tag.fontId;

            if (font == null) {
                Log.warn('Font not found!');
            }
		}
		
		if (tag.hasFontClass) {
			//definition.font = tag.fontClass;
		}

        var bounds = tag.bounds.rect;
		definition.x = bounds.x;
		definition.y = bounds.y;
		definition.width = bounds.width;
		definition.height = bounds.height;

        texts.set(tag.characterId, definition);

        onComplete();
	}

    function processSymbol(symbol:SWFSymbol, onComplete:Void->Void) {
        var tag = cast data.getCharacter(symbol.tagId);

        // Only process Sprite Symbol
        if (Std.is(tag, TagDefineSprite)) {
            processTag(tag, function() {
                var definition = movieClips.get(symbol.tagId);
                definition.name = symbol.name;

                onComplete();
            });
        } else {
            onComplete();
        }
    }

    function processTag(tag:IDefinitionTag, onComplete:Void->Void) {
        // Stop if exists or null
        if (tag == null || definitions.exists(tag.characterId)) {
            onComplete();
            return;
        }

        definitions.set(tag.characterId, true);

        if (Std.is(tag, TagDefineSprite)) {
            addSprite(cast tag, onComplete);

            // TODO: Maybe eventually support this aka "scale9Grid"
            /*var grid = data.getScalingGrid(tag.characterId);
			if (grid != null) {
				var rect:Rectangle = grid.splitter.rect.clone();
				cast(displayObject, MovieClip).scale9BitmapGrid = rect;
			}*/

        } else if (Std.is(tag, TagDefineBits) || Std.is(tag, TagDefineBitsJPEG2) || Std.is(tag, TagDefineBitsLossless)) {
            addBitmap(cast tag, onComplete);
            
        } else if (Std.is(tag, TagDefineButton) || Std.is(tag, TagDefineButton2)) {
            
            // Will not support
            onComplete();
            
        } else if (Std.is(tag, TagDefineEditText)) {
            addDynamicText(cast tag, onComplete);
            
        } else if (Std.is(tag, TagDefineText)) {
            // TODO: Static Text
            onComplete();
            
        } else if (Std.is(tag, TagDefineShape)) {
            addShape(cast tag, onComplete);
            
        } else if (Std.is(tag, TagDefineFont) || Std.is(tag, TagDefineFont4)) {
            addFont(cast tag, onComplete);
            
        } else if (Std.is(tag, TagDefineSound)) {

            // Will not support
            onComplete();

        } else {
            onComplete();
        }
    }
}