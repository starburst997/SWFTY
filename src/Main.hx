package;

import file.save.FileSave;

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
			var zip = exporter.getSwfty();

			trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');

			// Save file for test
			FileSave.saveClickBytes(zip, 'Test.swfty');

			// Showing Tilemap for fun
			var tilemap = exporter.getTilemap();
			var bmp = new Bitmap(tilemap.bitmapData);
			bmp.y = 0;
			addChild(bmp);
		});
	}
}