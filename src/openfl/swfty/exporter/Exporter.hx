package openfl.swfty.exporter;

import format.abc.Data.NamespaceSet;
import openfl.swfty.exporter.Shape;
import openfl.swfty.exporter.MovieClip;
import openfl.swfty.exporter.FontExporter;
import openfl.swfty.exporter.TilemapExporter;

import zip.ZipWriter;

import haxe.ds.IntMap;
import haxe.ds.Option;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

import openfl.filters.*;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.utils.ByteArray;

import lime.graphics.Image;
import lime.graphics.ImageChannel;
import lime.math.Vector2;

import format.png.Data;
import format.png.Writer;

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

    var maxId:Int = -1;

    var name:String;
    var definitions:IntMap<Bool>;
    
    var movieClipsOrder:Array<MovieClipDefinition>;

    var movieClips:IntMap<MovieClipDefinition>;
    var shapes:IntMap<Array<ShapeDefinition>>;
    var bitmapToShapes:IntMap<Array<ShapeDefinition>>;
    var texts:IntMap<TextDefinition>;
    var fonts:IntMap<FontDefinition>;

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

    public static function create(bytes:ByteArray, ?name:String, onComplete:Exporter->Void) {
        return new Exporter(bytes, name, onComplete);
    }

    public function new(bytes:ByteArray, ?name:String, onComplete:Exporter->Void) {
        swf = new SWF(bytes);
        data = swf.data;

        this.name = name == null ? 'NoName' : name;

        movieClipsOrder = [];

        definitions = new IntMap();
        
        movieClips = new IntMap();
        shapes = new IntMap();
        texts = new IntMap();
        fonts = new IntMap();
        bitmaps = new IntMap();
        bitmapDatas = new IntMap();
        bitmapToShapes = new IntMap();

        bitmapKeeps = new IntMap();
        processShapes = new IntMap();

        fontTilemaps = new IntMap();

        BitmapData.premultipliedDefault = true;

        // TODO: Remove listener
        openfl.Lib.current.addEventListener(Event.ENTER_FRAME, (_) -> {
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
                    if (processFrame++ < 250) {
                        f(i + 1);
                    } else {
                        nextFrames.push(() -> f(i + 1));
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
                        
                        bitmapData.draw(shape, m);

                        var definition:BitmapDefinition = {
                            id: id,
                            x: 0,
                            y: 0,
                            width: bitmapData.width,
                            height: bitmapData.height
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
                        var fontTilemap = FontExporter.export(#if html5 font.cleanName #else font.name #end, font.size, font.bold, font.italic, () -> ++maxId);

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
                        font.characters = fontTilemap.characters.map(char -> {
                            id: char.id,
                            bitmap: char.bitmap,
                            tx: char.tx,
                            ty: char.ty
                        });

                        fontTilemaps.set(id, fontTilemap);
                    }

                    onComplete(this);
                }
            }

            if (Std.is(tag, TagSymbolClass)) {
                var symbols = cast (tag, TagSymbolClass).symbols;
                
                //trace('TAG: ${tag.name} ${tag.toString()}');
                
                function process2(j) {
                    var symbol = symbols[j];
                    processSymbol(symbol, () -> {
                        if (j + 1 < symbols.length) process2(j + 1) else complete();                        
                    });
                }

                if (symbols.length > 0) process2(0) else complete();
            } else {
                complete();
            }
        }
        if (data.tags.length > 0) process(0) else onComplete(this);
    }

    public function getTilemap() {
        return switch(tilemap) {
            case Some(tilemap) : tilemap;
            case None : 
                // Create Tilemap based on all bitmapDatas
                var keys = [for (key in bitmapDatas.keys()) key];
                var bmpds = keys.map(key -> bitmapKeeps.exists(key) ? bitmapDatas.get(key) : null);
                var tilemap = TilemapExporter.pack(bmpds);

                // Remove all duplicates
                // TODO: !!!

                // Process all bitmaps and figure out the max scale
                // TODO: For "real" shapes, we might want to do that before doing the screenshot
                for (key in keys) if (bitmapKeeps.exists(key)) {
                    var bitmap = bitmaps.get(key);
                    

                    trace(bitmap.id);
                }

                // We're done, so go back to default
                BitmapData.premultipliedDefault = true;

                trace('Tilemap is ${tilemap.bitmapData.width}x${tilemap.bitmapData.height}');

                for (i in 0...keys.length) {
                    var key = keys[i];

                    var bitmap = bitmaps.get(key);
                    var tile = tilemap.tiles[i];
                    
                    if (tile != null) {
                        bitmap.x = tile.x;
                        bitmap.y = tile.y;
                    }
                }

                for (key in fontTilemaps.keys()) {
                    var font = fontTilemaps.get(key);
                    var fontTile = bitmaps.get(key);
                    font.characters.iter(char -> {
                        var tile = {
                            id: char.bitmap,
                            x: fontTile.x + char.x,
                            y: fontTile.y + char.y,
                            width: char.width,
                            height: char.height
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
                    height: tilemap.bitmapData.height
                }
                case None : {
                    width: 0,
                    height: 0
                }
            },
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
        #if sys
        // TODO: Run pngquant!!!
        #end
        return bmpd.encode(bmpd.rect, new PNGEncoderOptions());
    }

    // The whole point of this library was so I could get to name this function
    public function getSwfty(useJson = false, compressed = true) {
        var tilemap = getTilemap();
        var png = getPNG(tilemap.bitmapData);

        var zip = new ZipWriter();
        zip.addBytes(png, 'tilemap.png', false);
        
        if (useJson) {
            zip.addString(getJSON(), 'definitions.json', compressed);
        } else {
            zip.addBytes(getBinary(), 'definitions.bin', compressed);
        }

        return zip.finalize();
    }

    // This gives us optional compile-time swfty to our safety
    public function getAbstracts() {
        var swfty = SWFTYType.fromJson(getSWFTYJson());
        return ClassExporter.export(swfty, name);
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

                processTag(childTag, () -> {
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
                        (placeTag.colorTransform.rMult != 1.0 || 
                        placeTag.colorTransform.gMult != 1.0 || 
                        placeTag.colorTransform.bMult != 1.0 || 
                        placeTag.colorTransform.rAdd != 0 || 
                        placeTag.colorTransform.gAdd != 0 || 
                        placeTag.colorTransform.bAdd != 0);

                    if (placeTag.hasFilterList || (placeTag.hasCacheAsBitmap && placeTag.bitmapCache != 0) /*|| hasColor*/ /*|| placeTag.hasBlendMode*/) {
                        // TODO: Basically like cacheAsBitmap, take a screenshot of the MovieClip
                        //       Create a unique ID to prevent duplicates

                        if (Std.is(childTag, TagDefineSprite)) {
                            var movieClip = new MovieClip(this, cast childTag);

                            // TODO: OpenFL doesn't support inner / knockout !!
                            if (placeTag.hasFilterList) {
                                var filters:Array<BitmapFilter> = [];
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
                                                filters.push (new GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout));   
                                        }
                                    }
                                }
                                
                                movieClip.filters = filters;
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
                            
                            bitmapData.draw(movieClip, m);

                            var trimmed = TilemapExporter.trim(bitmapData);

                            shape.tx = bounds.x + trimmed.rect.x - padding;
                            shape.ty = bounds.y + trimmed.rect.y - padding;

                            var definition:BitmapDefinition = {
                                id: id,
                                x: 0,
                                y: 0,
                                width: trimmed.bmpd.width,
                                height: trimmed.bmpd.height
                            };

                            bitmaps.set(id, definition);
                            bitmapDatas.set(id, trimmed.bmpd);
                            bitmapKeeps.set(id, true);

                            shapes.set(characterId, [shape]);
                        }
                    }

                    var visible = if (placeTag.hasVisible) {
                        placeTag.visible != 0;
                    } else {
                        true;
                    }

                    if (mask != null && !isMask) trace('Found a masked object');

                    // TODO: Any property with default values should be ignored (for optional field)

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
                        color: if (hasColor) {
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

                    if (j + 1 < objects.length) process2(j + 1) 
                    // TODO: Only process 1 frame for now...
                    //else if (i + 1 < tag.frames.length) process(i + 1) 
                    else onComplete();

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

                processTag(cast data.getCharacter(bitmap.id), () -> {
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

                    if (i + 1 < bitmaps.length) f(i + 1) else onComplete();
                });
            }

            if (bitmaps.length > 0) process(0) else onComplete();
        } else {
            
            //processShapes.push(tag);
            //onComplete();

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

            var process = function f(i) {
                var command = handler.commands[i];
                switch(command) {
					case BeginBitmapFill(bitmapID, _, _, _):
						processTag(cast data.getCharacter(bitmapID), () -> {
                            if (i + 1 < handler.commands.length) f(i + 1) else onComplete();
                        });
					default:
                        if (i + 1 < handler.commands.length) f(i + 1) else onComplete();
				}
            }
            if (handler.commands.length > 0) process(0) else onComplete();
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
                    height: bitmapData.height
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
                BitmapData.loadFromBytes(output.getBytes()).onComplete((bmpd) -> {
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
        definition.text = r.replace(definition.html.replace('</p>', '\n').replace('&apos;', '\''), '');
        
        // Always have a new line at the end, remove
        definition.text = definition.text.substr(0, definition.text.length - 1);

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
            processTag(tag, () -> {
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