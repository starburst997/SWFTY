package;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.utils.ByteArray;

import lime.graphics.Image;

import format.png.Data;
import format.png.Writer;
import format.tools.Deflate;

import format.swf.exporters.ShapeBitmapExporter;
import format.swf.exporters.ShapeCommandExporter;
import format.swf.data.consts.BitmapFormat;
import format.swf.data.consts.BlendMode;
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

using Lambda;

typedef Transform = {
    x: Float,
	y: Float,
	scaleX: Float,
	scaleY: Float,
	rotation: Float,
}

typedef ShapeDefinition = {
    > Transform,
    id: Int,
    bitmap: Int,
}

typedef SpriteDefinition = {
	> Transform,
    id: Int,
    shapes: Array<ShapeDefinition>,
	name: String,
    visible: Bool
}

typedef BitmapDefinition = {
	id: Int,
	x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef MovieClipDefinition = {
	id: Int,
    name: String,
	children: Array<SpriteDefinition>
}

typedef SWFTileJson = {
	definitions: Array<MovieClipDefinition>,
    tiles: Array<BitmapDefinition>
}

class SWFTileExporter {

    var definitions:IntMap<Bool>;
    
    var movieClips:IntMap<MovieClipDefinition>;
    var shapes:IntMap<Array<ShapeDefinition>>;

    var bitmaps:IntMap<BitmapDefinition>;
    var bitmapDatas:IntMap<BitmapData>;

    var swf:SWF;
    var data:SWFRoot;

    var alphaPalette:Bytes;

    public function new(bytes:Bytes) {
        swf = new SWF(bytes);
        data = swf.data;

        definitions = new IntMap();
        
        movieClips = new IntMap();
        shapes = new IntMap();
        bitmaps = new IntMap();
        bitmapDatas = new IntMap();

        var json:SWFTileJson = {
            definitions: [],
            tiles: []
        };

        // TODO: Process root?

        for (tag in data.tags) {
            if (Std.is(tag, TagSymbolClass)) {
                for (symbol in cast (tag, TagSymbolClass).symbols) {
                    processSymbol(symbol);
                }
            }   
        }
    }

    public function getTilemap() {
        // Create Tilemap based on all bitmapDatas
        var bmpds = [for (bmpd in bitmapDatas) bmpd];
        var tilemap = TilemapExporter.pack(bmpds);

        var keys = [for (key in bitmapDatas.keys()) key];
        for (i in 0...keys.length) {
            var key = keys[i];

            var bitmap = bitmaps.get(key);
            var tile = tilemap.tiles[i];
            
            bitmap.x = tile.x;
            bitmap.y = tile.y;
        }

        return tilemap;
    }

    public function getJSON() {
        var definition:SWFTileJson = {
            definitions: [for (mc in movieClips) mc],
            tiles: [for (bmp in bitmaps) bmp]
        }

        return haxe.Json.stringify(definition);
    }

    public function getPNG(bmpd:BitmapData) {
        return bmpd.encode(bmpd.rect, new PNGEncoderOptions());
    }

    public function getSwfty() {
        // TODO: Change this library name to Swfty so I can name this function getSwfty

        var json = getJSON();
        var tilemap = getTilemap();
        var png = getPNG(tilemap.bitmapData);

        
    }

    function getTransform(matrix:Matrix):Transform {
        // TODO: Should we save the matrix instead? Easier to debug with those, since this is what we see in flash IDE
        var translation = {
            var offsetPoint:Point = new Point(0, 0);
            var transformedOffset:Point = matrix.deltaTransformPoint(offsetPoint);
            new Point(matrix.tx + transformedOffset.x, matrix.ty + transformedOffset.y);
        }

        return {
            x: translation.x,
            y: translation.y,
            scaleX: Math.sqrt(matrix.a*matrix.a + matrix.b*matrix.b),
            scaleY: Math.sqrt(matrix.c*matrix.c + matrix.d*matrix.d),
            rotation: {
                // extract translation
                var point = new Point(0, 0);
                var m = matrix.clone();
                var point2 = m.transformPoint(point);
                m.translate(-point2.x, -point2.y);

                // extract (uniform) scale...
                point.x = 1; point.y = 0;
                point = m.transformPoint(point);

                // ...and rotation
                Math.atan2(point.y, point.x) * 180/Math.PI;
            }
        }
    }

    function addSprite(tag:SWFTimelineContainer, root:Bool = false):MovieClipDefinition {
        
        var id = if (Std.is (tag, IDefinitionTag)) {
			untyped tag.characterId;
		} else {
            -1;
        }

        var children = [];
        var definition:MovieClipDefinition = {
            id: id,
            name: '',
            children: children
        }

        movieClips.set(id, definition);

        for (frameData in tag.frames) {
            for (object in frameData.getObjectsSortedByDepth()) {

                var childTag = cast data.getCharacter(object.characterId);
                processTag(childTag);

                var placeTag:TagPlaceObject = cast tag.tags[object.placedAtIndex];

                var matrix = if (placeTag.matrix != null) {
					var matrix = placeTag.matrix.matrix;
					matrix.tx *= (1 / 20);
					matrix.ty *= (1 / 20);
                    matrix;
				} else {
                    new Matrix();
                }

                if (placeTag.colorTransform != null) {
                    // TODO: ColorTransform
                }

                if (placeTag.hasFilterList) {
                    // TODO: Filters list
                }

                var visible = if (placeTag.hasVisible) {
                    placeTag.visible != 0;
                } else {
                    true;
                }

                if (placeTag.hasBlendMode) {
                    // TODO: Blend mode
                }

                if (placeTag.hasCacheAsBitmap) {
                    // TODO: Cache as Bitmap
                }

                var transform = getTransform(matrix);
                var definition:SpriteDefinition = {
                    id: object.characterId,
                    name: placeTag.instanceName,
                    x: transform.x,
                    y: transform.y,
                    scaleX: transform.scaleX,
                    scaleY: transform.scaleY,
                    rotation: transform.rotation,
                    visible: visible,
                    shapes: shapes.exists(object.characterId) ? shapes.get(object.characterId) : []
                }

                children.push(definition);
            }

            // TODO: Only support one frame for now
            break;
        }

        return definition;
    }

    function addShape(tag:TagDefineShape) {
        var handler = new ShapeCommandExporter(data);
		tag.export(handler);

        var bitmaps = ShapeBitmapExporter.process(handler);

        var shapes = [];

        if (bitmaps != null) {
            for (i in 0...bitmaps.length) {
                var bitmap = bitmaps[i];

                processTag(cast data.getCharacter(bitmap.id));

                var transform = getTransform(bitmap.transform);
                var definition:ShapeDefinition = {
                    id: i,
                    bitmap: bitmap.id,
                    x: transform.x,
                    y: transform.y,
                    scaleX: transform.scaleX,
                    scaleY: transform.scaleY,
                    rotation: transform.rotation
                }

                shapes.push(definition);
            }
        } else {
            for (i in 0...handler.commands.length) {
				var command = handler.commands[i];
                switch(command) {
					case BeginBitmapFill(bitmapID, _, _, _):
						processTag(cast data.getCharacter(bitmapID));

                        var definition:ShapeDefinition = {
                            id: i,
                            bitmap: bitmapID,
                            x: 0.0,
                            y: 0.0,
                            scaleX: 1.0,
                            scaleY: 1.0,
                            rotation: 0.0
                        }

                        shapes.push(definition);

					default:
				}
			}
        }

        this.shapes.set(tag.characterId, shapes);
    }

    function addBitmap(tag:IDefinitionTag) {

        var bitmapData = null;
		
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
				png.add(CData(Deflate.run(values)));
				png.add(CEnd);
				
				var output = new BytesOutput();
				var writer = new Writer(output);
				writer.write(png);
				
                bitmapData = BitmapData.fromBytes(output.getBytes());

			} else {

				bitmapData = new BitmapData(data.bitmapWidth, data.bitmapHeight, transparent);
				
				bitmapData.image.buffer.premultiplied = false;
				bitmapData.setPixels(bitmapData.rect, buffer);
				bitmapData.image.buffer.premultiplied = true;
				bitmapData.image.premultiplied = false;
				
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
				
				var image = Image.fromBytes(data.bitmapData);
				
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
				png.add(CData(Deflate.run (values)));
				png.add(CEnd);
				
				var output = new BytesOutput();
				var writer = new Writer(output);
				writer.write(png);
				
                var bitmapDataAlpha = BitmapData.fromBytes(output.getBytes());
                var bitmapDataJPEG = BitmapData.fromImage(image);

                bitmapData = new BitmapData(image.width, image.height, true, 0x00000000);
                bitmapData.copyPixels(bitmapDataJPEG, bitmapDataJPEG.rect, new Point(0, 0), bitmapDataAlpha, new Point(0, 0), true);
				
			} else {
				bitmapData = BitmapData.fromBytes(data.bitmapData);
			}
			
		} else if (Std.is(tag, TagDefineBits)) {
			
            var data:TagDefineBits = cast tag;
            bitmapData = BitmapData.fromBytes(data.bitmapData);
		}
		
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
		}
    }

    function processSymbol(symbol:SWFSymbol) {
        var tag = cast data.getCharacter(symbol.tagId);

        // Only process Sprite Symbol
        if (Std.is(tag, TagDefineSprite)) {
            processTag(tag);

            var definition = movieClips.get(symbol.tagId);
            definition.name = symbol.name;

            trace('MC', definition);
        }
    }

    function processTag(tag:IDefinitionTag) {
        // Stop if exists or null
        if (tag == null || definitions.exists(tag.characterId)) return;

        definitions.set(tag.characterId, true);

        if (Std.is(tag, TagDefineSprite)) {
            
            addSprite(cast tag);

        } else if (Std.is(tag, TagDefineBits) || Std.is(tag, TagDefineBitsJPEG2) || Std.is(tag, TagDefineBitsLossless)) {
            
            addBitmap(cast tag);
            
        } else if (Std.is(tag, TagDefineButton) || Std.is(tag, TagDefineButton2)) {
            
            // Will not support
            
        } else if (Std.is(tag, TagDefineEditText)) {
            
            // TODO: Dynamic Text
            
        } else if (Std.is(tag, TagDefineText)) {
            
            // TODO: Static Text
            
        } else if (Std.is(tag, TagDefineShape)) {
            
            addShape(cast tag);
            
        } else if (Std.is(tag, TagDefineFont) || Std.is(tag, TagDefineFont4)) {
            
            // Will not support
            
        } else if (Std.is(tag, TagDefineSound)) {

            // Will not support

        }
    }
}