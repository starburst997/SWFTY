package;

import haxe.io.Bytes;
import haxe.ds.StringMap;
import haxe.ds.IntMap;

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

typedef SpriteDefinition = {
	id: String,
	name: String,
	x: Float,
	y: Float,
	scaleX: Float,
	scaleY: Float,
	rotation: Float
}

typedef BitmapDefinition = {
	id: String,
	x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef MovieClipDefinition = {
	id: String,
	bitmap: String,
	children: Array<SpriteDefinition>,
}

typedef SWFTileJson = {
	definitions: Array<String>
}

class SWFTileExporter {

    var definitions:IntMap<Bool>;
    
    var swf:SWF;
    var data:SWFRoot;

    public function new(bytes:Bytes) {
        swf = new SWF(bytes);
        data = swf.data;

        definitions = new IntMap();

        var json:SWFTileJson = {
            definitions: []
        };

        for (tag in data.tags) {
            if (Std.is(tag, TagSymbolClass)) {
                for (symbol in cast (tag, TagSymbolClass).symbols) {
                    processSymbol(symbol);
                }
            }   
        }
    }

    function addSprite(tag:SWFTimelineContainer, root:Bool = false) {
        trace('Sprite!!');

        for (frameData in tag.frames) {

            for (object in frameData.getObjectsSortedByDepth()) {
                trace(object);
            }

            // TODO: Only support one frame for now
            break;
        }
    }

    function processSymbol(symbol:SWFSymbol) {
        var tag = cast data.getCharacter(symbol.tagId);
        processTag(tag);
    }

    function processTag(tag:IDefinitionTag) {
        // Stop if exists or null
        if (tag == null || definitions.exists(tag.characterId)) return;

        if (Std.is(tag, TagDefineSprite)) {
            
            addSprite(cast tag);

        } else if (Std.is(tag, TagDefineBits) || Std.is(tag, TagDefineBitsJPEG2) || Std.is(tag, TagDefineBitsLossless)) {
            
            // TODO: Bitmap

            trace('Bitmap!!');
            
        } else if (Std.is(tag, TagDefineButton) || Std.is(tag, TagDefineButton2)) {
            
            // Will not support
            
        } else if (Std.is(tag, TagDefineEditText)) {
            
            // TODO: Dynamic Text
            
        } else if (Std.is(tag, TagDefineText)) {
            
            // TODO: Static Text
            
        } else if (Std.is(tag, TagDefineShape)) {
            
            // Will not support (could do a screenshot perhaps?)
            
        } else if (Std.is(tag, TagDefineFont) || Std.is(tag, TagDefineFont4)) {
            
            // Will not support
            
        } else if (Std.is(tag, TagDefineSound)) {

            // Will not support

        }
    }
}