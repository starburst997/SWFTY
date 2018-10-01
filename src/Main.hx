package;

import file.save.FileSave;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;

using StringTools;

class Main extends Sprite {

	public function new() {	
		super();

		// Process SWF
		var layer = renderSWFTY('res/Test2.swfty', layer -> {
            
            trace('Yay loading finished!');

        }, error -> {
            trace('Error: $error');
        });

        addChild(layer);
	}

	public function renderSWFTY(path:String, onComplete:SWFTYLayer->Void, onError:Dynamic->Void) {
		var layer = SWFTYLayer.create(stage.stageWidth, stage.stageHeight);
        
        Assets
		.loadBytes(path)
		.onError(function(error) {
			trace('Error!!!', error);
            onError(error);
		})
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();
			
            layer.load(bytes, () -> onComplete(layer), () -> onError('Cannot load!'));
            
            trace('Parsed SWFTY: ${haxe.Timer.stamp() - timer}');
            
            onComplete(layer);
		});

        return layer;
	}
}