package;

import swfty.renderer.Layer;

class Main extends hxd.App {

    var debugInitialized = false;
    
    var info1Text:h2d.Text;
    var info2Text:h2d.Text;
    var info3Text:h2d.Text;

    // TODO: Hack until hxd.System.Platform works
    var isMobile = #if mobile true #else false #end;

    override function setup() {
        #if mobile
        @:privateAccess stage.window.displayMode = sdl.Window.DisplayMode.Fullscreen;
        #end

        // Looks terrible, doesn't work on iOS
        //stage.vsync = false;
        
        super.setup();
    }

    override function init() {
        super.init();

        hxd.Stage.getInstance().addEventTarget(onEvent);

        trace('Hello!');

        renderSWFTYAsync('Popup.swfty', layer -> {
            s2d.addChild(layer);
            trace('Done!');
        }, error -> {
            trace('Error: $error');
        });

        onResize();
    }

    override function onResize() {
        var stage = hxd.Stage.getInstance();
        var e = h3d.Engine.getCurrent();

        @:privateAccess trace('RESIZE', s2d.width, s2d.height, stage.window.drawableWidth, stage.window.drawableHeight);
        
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

    override function update(dt:Float) {
        super.update(dt);
        
        #if test
        printDebug();
        #end
    }

    override function render(e:h3d.Engine) {
        super.render(e);
    }

    public function renderSWFTYAsync(path:String, onComplete:Layer->Void, onError:Dynamic->Void) {
		var file = hxd.Res.load(path);
        var bytes = file.entry.getBytes();

        trace('Loaded ${bytes.length}');

        var timer = haxe.Timer.stamp();
        
        Layer.createAsync(bytes, layer -> onComplete(layer), (e) -> onError('Cannot load: $e!'));
        
        trace('Parsed SWFTY: ${haxe.Timer.stamp() - timer}');
	}

    function printDebug() {
        if (!debugInitialized) {
            debugInitialized = true;

            var font = hxd.Res.fonts.debug_fnt.toFont();
            if (info1Text == null) info1Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(1.0).setAlpha(1.0);
            if (info2Text == null) info2Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(1.0).setAlpha(1.0);
            if (info3Text == null) info3Text = font.text(s2d).setSpacing(0).setAlign(h2d.Text.Align.Left).changeScale(1.0).setAlpha(1.0);
            
            info1Text.setPosition(20.0, 20.0);
            info2Text.setPosition(20.0, 50.0);
            info3Text.setPosition(20.0, 80.0);

        }
        
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
        
        info2Text.setText('bufMem ${MB(sum)} (${MB(freeMem)}), totTex: ${MB(totTex)}, Total ${MB(totalMem)}');
        info3Text.setText('Buffers [${stats.bufferCount}] Textures [${stats.textureCount}] [${stats.bufferCount + stats.textureCount}]');
    }

    static function main() {
        #if html5
        // TODO : Download res instead
        hxd.Res.initEmbed();
        #else
        hxd.Res.initLocal();
        #end

        new Main();
    }
}