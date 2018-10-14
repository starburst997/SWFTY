package openfl.swfty.exporter;

import format.swf.instance.*;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton2;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagDefineMorphShape;
import format.swf.SWFTimelineContainer;

import openfl.geom.Rectangle;
import openfl.display.DisplayObject;

import openfl.swfty.exporter.Bitmap;
import openfl.swfty.exporter.Shape;

class MovieClip extends format.swf.instance.MovieClip {
	
    var exporter:Exporter;

	public function new(exporter:Exporter, data:SWFTimelineContainer) {		
		this.exporter = exporter;
        
        super(data);
	}

    override private inline function getDisplayObject(charId:Int):DisplayObject {
		
		var displayObject:DisplayObject = null;
		
		var symbol = data.getCharacter (charId);
		
		if (Std.is (symbol, TagDefineSprite)) {
			displayObject = new MovieClip(exporter, cast symbol);
			var grid = data.getScalingGrid (charId);
			if (grid != null) {
				var rect:Rectangle = grid.splitter.rect.clone ();
				
				cast (displayObject, MovieClip).scale9BitmapGrid = rect;
			}
			
		} else if (Std.is (symbol, TagDefineBitsLossless) || Std.is (symbol, TagDefineBits)) {
			displayObject = new Bitmap (exporter, cast symbol);
			
		} else if (Std.is (symbol, TagDefineShape)) {
			displayObject = new Shape (exporter, data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineText)) {
			
			displayObject = new StaticText (data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineEditText)) {
			
			displayObject = new DynamicText (data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineButton2)) {
			
			displayObject = new SimpleButton(data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineMorphShape)) {
			
			displayObject = new MorphShape(data, cast symbol);
			
		} else {
			
			//trace("Warning: No SWF Support for " + Type.getClassName(Type.getClass(symbol)));
			
		}
		
		return displayObject;
	}
}