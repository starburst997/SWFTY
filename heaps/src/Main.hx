package;

class Main extends hxd.App {

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

        trace('Hello!');

        
    }

    override function update(dt:Float) {
        super.update(dt);
    }

    override function render(e:h3d.Engine) {
        super.render(e);
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