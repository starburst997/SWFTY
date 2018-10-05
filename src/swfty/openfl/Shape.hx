package swfty.openfl;


import format.swf.exporters.ShapeCommandExporter;
import format.swf.instance.Bitmap;
import format.swf.tags.TagDefineShape;
import format.swf.SWFTimelineContainer;


class Shape extends flash.display.Shape {
	
	
	public function new (exporter:Exporter, data:SWFTimelineContainer, tag:TagDefineShape) {
		
		super ();
		
		if (tag != null) {
			
			var handler = new ShapeCommandExporter (data);
			tag.export (handler);
			
			for (command in handler.commands) {
				
				switch (command) {
					
					case BeginFill (color, alpha):
						
						graphics.beginFill (color, alpha);
					
					case BeginBitmapFill (bitmapID, matrix, repeat, smooth):
						
                        var bmpd = exporter.bitmapDatas.get (bitmapID);
						if (bmpd != null) {
							
							graphics.beginBitmapFill (bmpd, matrix, repeat, smooth);
							
						}
					
					case BeginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):
						
						#if (cpp || neko)
						cacheAsBitmap = true;
						#end
						graphics.beginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
					
					case CurveTo (controlX, controlY, anchorX, anchorY):
						
						#if (cpp || neko)
						cacheAsBitmap = true;
						#end
						graphics.curveTo (controlX, controlY, anchorX, anchorY);
					
					case EndFill:
						
						graphics.endFill ();
					
					case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
						
						if (thickness != null) {
							
							graphics.lineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
							
						} else {
							
							graphics.lineStyle ();
							
						}
					
					case LineTo (x, y):
						
						graphics.lineTo (x, y);
					
					case MoveTo (x, y):
						
						graphics.moveTo (x, y);
					
				}
				
			}
			
		}
		
	}
	
	
}