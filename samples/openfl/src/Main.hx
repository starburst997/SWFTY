package;

import swfty.exporter.Exporter;
import swfty.renderer.Layer;

import openfl.swfty.exporter.FontExporter;

import file.save.FileSave;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;

using swfty.utils.Tools;

class Main extends Sprite {

    var afterFrames:Array<Void->Void> = [];

    var layer:Layer;
    var sprites:Array<Sprite> = [];

    var dt = 0.0;
    var timer = 0.0;

	public function new() {	
		super();

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.textColor = 0x000000;
        this.addChild(fps);

        /*var font = FontExporter.export('Bango', 24, false, false, iso8859_1);
        var bmp = new Bitmap(font.bitmapData);

        addChild(bmp);*/

        process();
    }

    function process() {
		// Process SWF

        // Asynchronous creation
        processSWF('res/Popup.swf', layer -> {
        //renderSWFTY('res/Popup.swfty', layer -> {

        /*({
            // Synchronous creation
            var layer = renderSWFTY('res/Popup.swfty', layer -> {
                trace('Yay loading finished!');
            }, error -> {
                trace('Error: $error');
            });*/

            /*var bmp = new Bitmap(layer.tileset.bitmapData);
            addChild(bmp);*/

            var names = layer.getAllNames();
            //trace(names);

            //trace(Report.getReport(layer.json));

            addChildAt(layer, 0);

            var sprite = layer.get('PopupShop');
            sprite.x += 0;
            sprite.scaleX = sprite.scaleY = 0.75;
            layer.add(sprite);

            //return;

            // TODO: VSCode was choking on the naming, not sure why but this did the trick
            var spawn = function f() {
                haxe.Timer.delay(() -> {
                    var name = names[Std.int(Math.random() * names.length)];
                    var sprite = layer.get(name);

                    var speedX = Math.random() * 50 - 25;
                    var speedY = Math.random() * 50 - 25;
                    var speedRotation = (Math.random() * 50 - 25) / 180 * Math.PI * 5;
                    var speedAlpha = Math.random() * 0.75 + 0.25;

                    speedRotation = speedRotation / Math.PI * 180;

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
                            layer.remove(sprite);
                            removeEventListener(Event.ENTER_FRAME, render);
                        }
                    }

                    addEventListener(Event.ENTER_FRAME, render);
                    //sprites.push(sprite);

                    layer.add(sprite);

                    f();

                }, Std.int(DateTools.seconds(0.01)));
            }

            spawn();
            
            stage.addEventListener(Event.ENTER_FRAME, render);
        });
	}

    function render(e) {
        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();
    }

    public function renderSWFTY(path:String, ?onComplete:Layer->Void, ?onError:Dynamic->Void) {
		var layer = Layer.create(stage.stageWidth, stage.stageHeight);
        
        Assets
		.loadBytes(path)
		.onError(onError)
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();
			
            layer.load(bytes, () -> if (onComplete != null) onComplete(layer), onError);
            
            trace('Parsed SWFTY: ${haxe.Timer.stamp() - timer}');
		});

        return layer;
	}

    public function processSWF(path:String, ?onComplete:Layer->Void, ?onError:Dynamic->Void) {
		var layer = Layer.create(stage.stageWidth, stage.stageHeight);

        Assets
		.loadBytes(path)
		.onError(onError)
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

            // Get name from path
            var name = new haxe.io.Path(path).file;

			var timer = haxe.Timer.stamp();
			Exporter.create(bytes, name, function(exporter) {
                // TODO: Could be more optimized by getting the tilemap + definition straigt from exporter object
                //       and passing it down to layer
                var bytes = exporter.getSwfty();
                layer.load(bytes, () -> if (onComplete != null) onComplete(layer), onError);
                
                // Save file for test
                FileSave.saveClickBytes(bytes, '$name.swfty');
                FileSave.saveClickString(exporter.getAbstracts(), '${name.capitalize()}.hx');

                trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
            });
		});

        return layer;
	}
}