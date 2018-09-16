package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;

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
	}
}