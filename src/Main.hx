package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;

class Main extends Sprite {
	
	public function new() {	
		super();
		
		// Process SWF
		processSWF('res/Test.swf');
	}

	function processSWF(path:String) {
		Assets
		.loadBytes(path)
		.onError(function(error) {
			trace('Error!!!', error);
		})
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();

			var exporter = new SWFTileExporter(bytes);
			var tilemap = exporter.getTilemap();

			trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');

			var bmp = new Bitmap(tilemap.bitmapData);
			bmp.y = 0;
			addChild(bmp);

			trace(bmp, bmp.width, bmp.height);
		});
	}
}