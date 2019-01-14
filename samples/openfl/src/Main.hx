package;

#if export
import swfty.exporter.Exporter;
import file.save.FileSave;
#end

import haxe.net.WebSocket;
import haxe.ds.IntMap;
import haxe.io.Bytes;

import swfty.renderer.Layer;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;

import hx.concurrent.executor.*;

using swfty.utils.Tools;
using swfty.extra.Lambda;
using swfty.extra.Tween;

class Main extends Sprite {

    var layers:Array<Layer>;

    var dt = 0.0;
    var timer = 0.0;

    var test = 0;

	public function new() {	
		super();

        var retry = false;

        addEventListener(MouseEvent.CLICK, function(_) {
            test = (test + 1) % 2;
        });

        #if (!swflite && !swf && !noServer)
        // This should be in your DEV code only
        // Start server
        var executor = Executor.create(1);
        var messages = new IntMap<{
            id: Int,
            total: Int,
            start: Float,
            time: Float,
            chunks: Array<{
                part: Int,
                bytes: Bytes
            }>
        }>();
        
        var startClient = function f():Void {

            // TODO: Get rid of message if it been over X sec

            var stop = false;
            var ws = WebSocket.create("ws://192.168.0.192:49463/", [], false);
            ws.onopen = function() {
                trace('open!');

                // Try again
                for (message in messages) {
                    var parts = [for (i in 0...message.total) i];
                    for (chunk in message.chunks) {
                        parts.remove(chunk.part);
                    }

                    var bytes = Bytes.alloc(parts.length * 4 + 2 + 4);
                    bytes.setUInt16(0, 0xDEDE);
                    bytes.setInt32(2, message.id);
                    for (i in 0...parts.length) {
                        var part = parts[i];
                        bytes.setInt32(2 + 4 + i * 4, part);
                    }

                    ws.sendBytes(bytes);
                }
            };
            ws.onclose = function() {
                trace('close!');
                stop = true;

                #if html5
                retry = true;
                #end
            };
            ws.onerror = function(e) {
                //trace('close!', e);
                //ws.close();
                //stop = true;
            };
            /*ws.onmessageString = function(message) {
                trace('message from server!' + (message.length > 200 ? message.substr(0, 200) + '...' : message));
                trace('message.length=' + message.length);
            };*/
            ws.onmessageBytes = function(bytes) {
                //trace('message bytes from server!', bytes.length);

                // Verify magic number
                if (bytes.getUInt16(0) == 0xCACA) {
                    var id = bytes.getInt32(2);
                    var part = bytes.getInt32(2 + 4);
                    var total = bytes.getInt32(2 + 4 + 4);

                    if (!messages.exists(id)) {
                        trace('Received new message', id);
                        messages.set(id, {
                            id: id,
                            start: Date.now().getTime(),
                            time: Date.now().getTime(),
                            total: total,
                            chunks: []
                        });
                    }

                    var message = messages.get(id);
                    message.time = Date.now().getTime();

                    // Skip duplicate
                    for (chunk in message.chunks) {
                        if (chunk.part == part) return;
                    }

                    message.chunks.push({
                        part: part,
                        bytes: bytes
                    });

                    //trace(id, part, message.chunks.length, total);
                    if (message.chunks.length == total) {
                        trace('Received all message (${Math.ceil((Date.now().getTime() - message.start) / 1000 * 100) / 100} sec)');

                        // Calculate size and read name<
                        var len = 0;
                        var name = '';
                        for (chunk in message.chunks) {
                            len += chunk.bytes.length - (2 + 4 + 4 + 4);

                            if (chunk.part == 0) {
                                var l = chunk.bytes.getInt32(2 + 4 + 4 + 4);
                                len -= l + 4;
                                name = chunk.bytes.getString(2 + 4 + 4 + 4 + 4, l);
                            }
                        }

                        // Create SWFTY bytes back
                        var n = 0;
                        var swfty = Bytes.alloc(len);
                        for (chunk in message.chunks.sortf(chunk -> chunk.part)) {
                            var skip = 2 + 4 + 4 + 4 + (chunk.part == 0 ? 4 + chunk.bytes.getInt32(2 + 4 + 4 + 4) : 0);

                            swfty.blit(n, chunk.bytes, skip, chunk.bytes.length - skip);
                            n += chunk.bytes.length - skip;
                        }

                        trace('Got SWFTY!', name, swfty.length);

                        for (layer in layers) {
                            if (layer.id == name) {
                                trace('Found a layer!');
                                layer.loadBytes(swfty);
                            }
                        }
                        
                        messages.remove(id);
                    }
                }
            };

            #if sys
            while (!stop) {
                ws.process();
                Sys.sleep(0.01);
            }
            #end
        };

        executor.submit(startClient);
        executor.onResult = function(_) {
            #if sys
            trace('ON RESULT!!! Restarting');
            haxe.Timer.delay(function() {
                executor.submit(startClient);
            }, 500);
            #end
        };
        #end

        // Test
        layers = [];

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.width = 200;
        fps.defaultTextFormat = new TextFormat(null, 40);
        fps.textColor = 0xFFFFFF;
        this.addChild(fps);

        /*var font = FontExporter.export('Bango', 24, false, false, iso8859_1);
        var bmp = new Bitmap(font.bitmapData);

        addChild(bmp);*/

        process();

        stage.addEventListener(Event.ENTER_FRAME, function(_) {
            #if (!swflite && !swf && !noServer)
            if (retry) {
                retry = false;
                haxe.Timer.delay(function() {
                    executor.submit(startClient);
                }, 500);
            }

            for (message in messages) {
                if (Date.now().getTime() - message.time > 60 * 1000) {
                    trace('Removed', message.id);
                    messages.remove(message.id);
                }
            }
            #end

            render();
        });
    }

    function process() {
		// Process SWF

        trace('Hello!');

        // Asynchronous creation
        #if (!swflite && !swf)
        #if export
        processSWF('res/Popup.swf', function(layer) {
        #else
        swfty.Yokat.load(stage.stageWidth, stage.stageHeight, function(layer:swfty.Yokat) {
        #end
            layers.push(layer);

            //trace(names);

            //trace(Report.getReport(layer.json));

            addChildAt(layer, 0);

            //var sprite = layer.create('UI');
            //layer.add(sprite);
            //sprite.fit();

        }, function(e) trace('ERROR: $e'));
        #end
	}

    var time = 0.0;
    function render() {
        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();

        for (layer in layers) {
            layer.update(dt);
        }

        time -= dt;
        if (time <= 0) {
            time = 0.60;

            #if (swflite || swf)
            var sprite = Assets.getMovieClip('Yokat:UI');

            var speedX = Math.random() * 50 - 25;
            var speedY = Math.random() * 50 - 25;
            var speedRotation = (Math.random() * 50 - 25) / 180 * Math.PI * 5;
            var speedAlpha = Math.random() * 0.75 + 0.25;

            sprite.x = Math.random() * stage.stageWidth * 0.75;
            sprite.y = Math.random() * stage.stageHeight * 0.75;

            var render = null;
            render = function(e) {
                sprite.x += speedX * dt;
                sprite.y += speedY * dt;
                sprite.rotation += speedRotation * dt;
                sprite.alpha -= speedAlpha * dt;

                if (sprite.alpha <= 0) {
                    removeChild(sprite);
                    removeEventListener(Event.ENTER_FRAME, render);
                }
            }

            addEventListener(Event.ENTER_FRAME, render);

            addChild(sprite);

            #else
            for (layer in layers) {
                var names = layer.getAllNames();
                for (i in 0...1) {
                    var name = 'UI';//names[Std.int(Math.random() * names.length)];
                    var sprite = layer.create(name);

                    var speedX = Math.random() * 50 - 25;
                    var speedY = Math.random() * 50 - 25;
                    var speedRotation = (Math.random() * 50 - 25) / 180 * Math.PI * 5;
                    var speedAlpha = Math.random() * 0.75 + 0.25;

                    sprite.x = Math.random() * stage.stageWidth * 0.75;
                    sprite.y = Math.random() * stage.stageHeight * 0.75;

                    var scale = Math.random() * 0.25 + 0.35;
                    sprite.scaleX = scale;
                    sprite.scaleY = scale;

                    //sprite.tweenScale(1.5, 0.5, 0.5, BounceOut, function() 
                    //    sprite.tweenScale(0.25, 0.5, BackIn));

                    sprite.addRender(function(dt) {
                        sprite.x += speedX * dt;
                        sprite.y += speedY * dt;
                        sprite.rotation += speedRotation * dt;
                        sprite.alpha -= speedAlpha * dt;

                        if (sprite.alpha <= 0) {
                            layer.remove(sprite);
                        }
                    });

                    layer.add(sprite);
                }
            }
            #end
        }
    }

    #if export
    public function processSWF(path:String, ?onComplete:Layer->Void, ?onError:Dynamic->Void) {
		var layer = Layer.empty(stage.stageWidth, stage.stageHeight);

        File.loadBytes(path, function(bytes) {
            // Get name from path
            var name = new haxe.io.Path(path).file;

			var timer = haxe.Timer.stamp();
			Exporter.create(bytes, name, function(exporter) {
                // TODO: Could be more optimized by getting the tilemap + definition straigt from exporter object
                //       and passing it down to layer
                var bytes = exporter.getSwfty();
                layer.loadBytes(bytes, function() if (onComplete != null) onComplete(layer), onError);
                
                // Save file for test
                FileSave.saveClickBytes(bytes, '$name.swfty');
                FileSave.saveClickString(exporter.getAbstracts(), '${name.capitalize()}.hx');

                trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
            }, onError);
        }, onError);

        return layer;
	}
    #end
}