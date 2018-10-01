package;

import file.save.FileSave;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.events.Event;
import openfl.Assets;

using StringTools;

class Main extends Sprite {

    var afterFrames:Array<Void->Void> = [];

    var layer:SWFTYLayer;
    var sprites:Array<SWFTYSprite> = [];

    var dt = 0.0;
    var timer = 0.0;

	public function new() {	
		super();

		// Process SWF
		//var layer = renderSWFTY('res/Test2.swfty', layer -> {
        //var layer = processSWF('res/Test1.swf', layer -> {
        renderSWFTYAsync('res/Test1.swfty', layer -> {
            trace('Yay loading finished!');

            var names = layer.getAllNames();
            trace(names);

            addChild(layer);

            function spawn() {
                haxe.Timer.delay(() -> {
                    var name = names[Std.int(Math.random() * names.length)];

                    var sprite = layer.get(name);
                    
                    var speedX = Math.random() * 50 - 25;
                    var speedY = Math.random() * 50 - 25;
                    var speedRotation = Math.random() * 50 - 25;
                    var speedAlpha = Math.random() * 0.75 + 0.25;

                    sprite.x = Math.random() * stage.stageWidth * 0.75;// + stage.stageWidth / 4;
                    sprite.y = Math.random() * stage.stageHeight * 0.75;// + stage.stageHeight / 4;

                    var scale = Math.random() * 0.25 + 0.35;
                    sprite.scaleX = scale;
                    sprite.scaleY = scale;

                    var render = null;
                    render = (e) -> {
                        sprite.x += speedX * dt;
                        sprite.y += speedY * dt;
                        sprite.rotation += speedRotation * dt;
                        sprite.alpha -= speedAlpha * dt;

                        if (sprite.alpha <= 0) {
                            layer.removeTile(sprite);
                            layer.removeEventListener(Event.ENTER_FRAME, render);
                        }
                    }
                    
                    layer.addEventListener(Event.ENTER_FRAME, render);
                    //sprites.push(sprite);

                    layer.addTile(sprite);

                    spawn();

                }, Std.int(DateTools.seconds(0.05)));
            }

            spawn();
            
            stage.addEventListener(Event.ENTER_FRAME, render);
        
        }, error -> {
            trace('Error: $error');
        });
	}

    function render(e) {
        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();
    }

	public function renderSWFTYAsync(path:String, onComplete:SWFTYLayer->Void, onError:Dynamic->Void) {
		Assets
		.loadBytes(path)
		.onError(function(error) {
			trace('Error!!!', error);
            onError(error);
		})
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();
			
            trace(stage.stageWidth, stage.stageHeight);
            SWFTYLayer.createAsync(stage.stageWidth, stage.stageHeight, bytes, layer -> onComplete(layer), (e) -> onError('Cannot load: $e!'));
            
            trace('Parsed SWFTY: ${haxe.Timer.stamp() - timer}');
		});
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
			
            layer.load(bytes, () -> onComplete(layer), (e) -> onError('Cannot load: $e!'));
            
            trace('Parsed SWFTY: ${haxe.Timer.stamp() - timer}');
		});

        return layer;
	}

    public function processSWF(path:String, onComplete:SWFTYLayer->Void, onError:Dynamic->Void) {
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
			SWFTYExporter.create(bytes, function(exporter) {
                // TODO: Could be more optimized by getting the tilemap + definition straigt from exporter object
                //       and passing it down to layer
                var bytes = exporter.getSwfty();
                layer.load(bytes, () -> onComplete(layer), (e) -> onError('Cannot load $e!'));
                
                // Save file for test
                FileSave.saveClickBytes(bytes, 'Test2.swfty');

                trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
            });
		});

        return layer;
	}
}