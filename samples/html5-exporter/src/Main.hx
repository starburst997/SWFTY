package;

import SWFTY;
import haxe.io.Bytes;

#if export
import swfty.exporter.Exporter;
import file.save.FileSave;
#end

import swfty.renderer.Layer;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextFormat;

using swfty.utils.Tools;
using swfty.extra.Lambda;
using swfty.extra.Tween;

class Main extends Sprite {

    public static var instance:Main;

    var layers:Array<Layer>;

    var dt = 0.0;
    var timer = 0.0;

	public function new() {	
        instance = this;

		super();

        layers = [];

        var fps:openfl.display.FPS = new openfl.display.FPS();
        fps.width = 200;
        fps.defaultTextFormat = new TextFormat(null, 40);
        fps.textColor = 0xFFFFFF;
        this.addChild(fps);

        openfl.Lib.current.graphics.beginFill(0x666666, 1.0);
        openfl.Lib.current.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        openfl.Lib.current.graphics.endFill();

        stage.addEventListener(Event.ENTER_FRAME, render);
    }

    public function renderSWFTY(bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        // Clear layers
        for (layer in layers) {
            removeChild(layer);
            layer.dispose();
        }

        // Load new layers
        layers = [];
        Layer.load(bytes, stage.stageWidth, stage.stageHeight, function(layer) {
            layers.push(layer);
            addChildAt(layer, 0);

            if (onComplete != null) onComplete();
        });
    }

    public function renderMC(name:String) {
        for (layer in layers) {
            layer.removeAll();

            var sprite = layer.create(name);
            layer.add(sprite);

            sprite.fit();
        }
    }

    var stressing = false;
    public function stress() {
        if (stressing) {
            stressing = false;
            return;
        }

		// Process SWF
        if (layers.length == 0) return;

        var layer = layers[0];
        var names = layer.getAllNames();

        stressing = true;

        var spawn = function f() {
            haxe.Timer.delay(function() {
                var name = names[Std.int(Math.random() * names.length)];
                var sprite = layer.create(name);

                var speedX = Math.random() * 50 - 25;
                var speedY = Math.random() * 50 - 25;
                var speedRotation = (Math.random() * 50 - 25) / 180 * Math.PI * 5;
                var speedAlpha = Math.random() * 0.75 + 0.25;

                speedRotation = speedRotation / Math.PI * 180;

                sprite.x = Math.random() * stage.stageWidth * 0.75;
                sprite.y = Math.random() * stage.stageHeight * 0.75;

                var scale = Math.random() * 0.25 + 0.35;
                sprite.scaleX = scale;
                sprite.scaleY = scale;

                sprite.tweenScale(1.5, 0.5, 0.5, BounceOut, function() 
                    sprite.tweenScale(0.25, 0.5, BackIn));

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

                if (stressing) f();

            }, Std.int(DateTools.seconds(0.0025)));
        }

        spawn();
	}

    function render(e) {
        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();

        for (layer in layers) {
            layer.update(dt);
        }
    }
}