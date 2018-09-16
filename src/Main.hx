package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;

import format.SWF;

class Main extends Sprite {
	
	public function new() {	
		super();
		
		Assets
		.loadBitmapData('res/ren.jpg')
		.onError(function(error) {
			trace('Error!!!', error);
		})
		.onComplete(function(bitmapData) {
			var bitmap = new Bitmap(bitmapData);
			addChild(bitmap);
		});

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

			var swf = new SWF(bytes);
			trace(swf);
		});
	}
}