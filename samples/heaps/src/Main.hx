package;

import swfty.renderer.Layer;

using swfty.extra.Lambda;
using swfty.extra.Tween;

class Main extends hxd.App {

    var debugInitialized = false;

    var info1Text:h2d.Text;
    var info2Text:h2d.Text;
    var info3Text:h2d.Text;

    var layers:Array<Layer>;

    // TODO: Hack until hxd.System.Platform works
    var isMobile = #if mobile true #else false #end;

    function new() {
        layers = [];
        
        super();
    }

    override function setup() {
        var window = hxd.Window.getInstance();

        #if mobile
        @:privateAccess window.window.displayMode = sdl.Window.DisplayMode.Fullscreen;
        #end

        //window.vsync = true;

        super.setup();
    }

    override function init() {
        super.init();

        var stage = hxd.Window.getInstance();

        s2d.defaultSmooth = true;
        stage.addEventTarget(onEvent);

        //var layer = Layer.load(stage.width, stage.height, 'swfty/high/Yokat.swfty', (layer:Layer) -> {    
        var layer = Layer.load(stage.width, stage.height, 'swfty/high/Popup.swfty', (layer:Layer) -> {    
            trace('Done!');
            
            var sprite:Sprite = layer.create('UI');
            layer.add(sprite);

            sprite.fit();

            //sprite.fit();
            //sprite.x += 408;
            //sprite.y += 208;
            //sprite.scaleX = 0.85;
            //sprite.scaleY = 0.85;
            //sprite.rotation = -1.0;

            //sprite.get('mc').get('description').getText('title').fitText('A very long title, yes, hello!!!');

            var names = layer.getAllNames();
            var spawn = function f() {
                haxe.Timer.delay(function() {
                    for (layer in layers) {
                        var name = names[Std.int(Math.random() * names.length)];
                        var sprite = layer.create(name);

                        var speedX = Math.random() * 50 - 25;
                        var speedY = Math.random() * 50 - 25;
                        var speedRotation = (Math.random() * 50 - 25) / 180 * Math.PI * 5;
                        var speedAlpha = Math.random() * 0.75 + 0.25;

                        sprite.x = Math.random() * stage.width * 0.75;// + stage.stageWidth / 4;
                        sprite.y = Math.random() * stage.height * 0.75;// + stage.stageHeight / 4;

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

                        f();
                    }
                }, Std.int(DateTools.seconds(0.0025)));
            }

            spawn();
        
        }, error -> {
            trace('Error: $error');
        });

        layers.push(layer);
        s2d.addChild(layer);

        #if test
        if (!debugInitialized) {
            debugInitialized = true;

            // TODO: Find a more elegant way for this
            #if js
            var font = hxd.Res.debug_fnt.toFont();
            #else
            var font = hxd.Res.fonts.debug_fnt.toFont();
            #end
            if (info1Text == null) info1Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(0.75).setAlpha(1.0);
            if (info2Text == null) info2Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(0.75).setAlpha(1.0);
            if (info3Text == null) info3Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(0.75).setAlpha(1.0);
            
            info1Text.setPosition(20.0, 20.0);
            info2Text.setPosition(20.0, 50.0);
            info3Text.setPosition(20.0, 80.0);
        }
        #end

        onResize();
    }

    override function onResize() {
        var stage = hxd.Window.getInstance();
        var e = h3d.Engine.getCurrent();

        #if hl
        @:privateAccess trace('RESIZE', s2d.width, s2d.height, stage.window.drawableWidth, stage.window.drawableHeight);
        #end

        #if hlsdl
        switch(hxd.System.platform) { // TODO: Not working
            case hxd.System.Platform.Android | hxd.System.Platform.IOS : isMobile = true;
            default:
        }
        
        // Fix retina display
        // TODO: Find a proper fix in hashlink / heaps
        @:privateAccess e.resize(stage.window.drawableWidth, stage.window.drawableHeight);
        #end
    }

    function onEvent(e:hxd.Event) {
        switch(e.kind) {
            case EKeyDown: switch(e.keyCode) {
                case hxd.Key.ESCAPE: hxd.System.exit();
                default:
            }
            default:
        }
    }

    var testAlpha = 0.0;
    override function update(dt:Float) {
        super.update(dt);

        for (layer in layers) {
            layer.update(dt);
        }

        #if test
        printDebug();
        #end
    }

    function printDebug() {
        if (debugInitialized) {
            var engine = h3d.Engine.getCurrent();

            //trace('FPS ${engine.fps}, Draw Call ${engine.drawCalls}, Draw Triangle ${engine.drawTriangles}');
            info1Text.setText('Draw Call ${engine.drawCalls}, Draw Triangle ${engine.drawTriangles}, FPS ${engine.fps}');

            var stats = engine.mem.stats();
            var idx = (stats.totalMemory - (stats.textureMemory + stats.managedMemory));
            var sum : Float = idx + stats.managedMemory;
            var freeMem : Float = stats.freeManagedMemory;
            var totTex : Float = stats.textureMemory;
            var totalMem : Float = stats.totalMemory;

            inline function MB(m:Float) return '${Math.ceil(m / 1024 / 1024 * 100) / 100}mb';

            //trace('bufMem ${sum} (${freeMem}), totTex: ${totTex}, Total ${totalMem}');
            //trace('Buffers [${stats.bufferCount}] Textures [${stats.textureCount}] [${stats.bufferCount + stats.textureCount}]');
            
            info2Text.setText('bufMem ${MB(sum)} (${MB(freeMem)}), totTex: ${MB(totTex)}');
            info3Text.setText('Total ${MB(totalMem)} Buffers [${stats.bufferCount}] Textures [${stats.textureCount}] [${stats.bufferCount + stats.textureCount}]');
        }
    }

    static function main() {
        #if js
        // I really wanted to load SWFTY and not have them embed
        hxd.Res.initEmbed();
        #else
        hxd.Res.initLocal();
        #end

        new Main();
    }
}