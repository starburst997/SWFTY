package swfty.extra;

import haxe.io.Bytes;
import haxe.ds.StringMap;

import swfty.renderer.Mouse;
import swfty.extra.Interaction;

// Manager all layers, usefull for some multi-layer logics like exclusive clicks
// Provide a main render loop to call
// TODO: Maybe this should be an extra?

class Manager {

    public static var ref(get, null):Manager;
    static inline function get_ref() {
        if (ref == null) ref = create();
        return ref;
    }

    public static inline function create() {
        return new Manager();
    }

    public var cache:StringMap<Bytes> = new StringMap();

    // Global scaled factor applied to all layers, usefull when dealing with multiple screen size
    public var scale(default, set):Float = 1.0;
    inline function set_scale(value:Float) {
        scale = value;
        for (layer in layers) layer.scale = scale;
        return value;
    }

    public var layers:Array<Layer> = [];
    public var dt = 0.0;

    public var mouse(default, null) = new Mouse(true);

    public var master:Layer = null;

    public var stopPropagation = false;

    public var fps = 60;
    var fpsCounter = 0;
    var fpsTimer = 0.0;

    var renders:Array<Void->Void> = [];
    var preRenders:Array<Void->Void> = [];
    var postRenders:Array<Void->Void> = [];
    var timer = 0.0;

    var pruneLayers:Array<Layer> = [];
    var pruneRenders:Array<Void->Void> = [];
    var prunePreRenders:Array<Void->Void> = [];
    var prunePostRenders:Array<Void->Void> = [];

    var onRemoves:Array<Layer->Void> = [];
    var pruneOnRemoves:Array<Layer->Void> = [];

    var clicks:Array<Array<Sprite>->Void> = [];

    public function new(interaction = true) {
        @:privateAccess if (interaction) Interactions.manage(this);
    }

    public function interactAll() {
        for (layer in layers) layer.shared.canInteract = true;
        return this;
    }

    public inline function getCache(name:String):Bytes {
        return cache.get(name);
    }

    public inline function hasCache(name:String):Bool {
        return cache.exists(name);
    }
 
    public inline function setCache(name:String, bytes:Bytes) {
        cache.set(name, bytes);
        return this;
    }

    public inline function clearCache() {
        cache = new StringMap();
        return this;
    }

    public inline function add(layer:Layer) {
        layer.scale = scale;
        layer.mouse = mouse;
        layers.push(layer);
        return this;
    }

    public inline function remove(layer:Layer) {
        layers.remove(layer);
        for (f in onRemoves) f(layer);
        return this;
    }

    public inline function addOnRemove(f:Layer->Void) {
        onRemoves.push(f);
        return this;
    }

    public inline function removeOnRemove(f:Layer->Void) {
        pruneOnRemoves.push(f);
        return this;
    }

    public inline function addRenderOnce(f:Void->Void) {
        function handler() {
            f();
            removeRender(handler);
        }
        
        return addRender(handler);
    }

    public inline function wait(wait:Float, f:Void->Void) {
        var time = haxe.Timer.stamp();
        function handler() {
            if (haxe.Timer.stamp() - time > wait) {
                f();
                removeRender(handler);
            }
        }
        
        return addRender(handler);
    }

    public inline function addRender(f:Void->Void) {
        renders.push(f);
        return this;
    }

    public inline function addPostRender(f:Void->Void) {
        postRenders.push(f);
        return this;
    }

    public inline function addPreRender(f:Void->Void) {
        preRenders.push(f);
        return this;
    }

    public inline function removeRender(f:Void->Void) {
        pruneRenders.push(f);
        return this;
    }

    public inline function removePreRender(f:Void->Void) {
        prunePreRenders.push(f);
        return this;
    }
    
    public inline function removePostRender(f:Void->Void) {
        prunePostRenders.push(f);
        return this;
    }

    function click(sprites:Array<Sprite>) {
        for (f in clicks) f(sprites);
    }

    public function addClick(f:Array<Sprite>->Void) {
        clicks.push(f);
        return this;
    }

    public function removeClick(f:Array<Sprite>->Void) {
        clicks.remove(f);
        return this;
    }

    public function postUpdate() {
        if (prunePostRenders.length > 0) {
            for (f in prunePostRenders) postRenders.remove(f);
            prunePostRenders = [];
        }
        
        for (f in postRenders) f();
    }

    public function update() {
        fpsCounter++;
        if (haxe.Timer.stamp() - fpsTimer > 1.0) {
            fps = fpsCounter;
            fpsCounter = 0;
            fpsTimer = haxe.Timer.stamp();
        }

        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();

        if (dt > 1/10.0) dt = 1/10.0;

        if (prunePreRenders.length > 0) {
            for (f in prunePreRenders) preRenders.remove(f);
            prunePreRenders = [];
        }

        for (f in preRenders) f();

        // TODO: Has a slight optimization we could call update() in order of rendering like calculateRenderID()
        //       However it might be interesting to have layers still having update() even when not rendered....
        for (layer in layers) {
            if (layer.disposed) {
                remove(layer);
            } else {
                layer.update(dt);
            }
        }

        // Calculate renderID
        if (master != null) {
            BaseLayer.baseID = 0;
            master.calculateRenderID();
        }

        if (pruneRenders.length > 0) {
            for (f in pruneRenders) renders.remove(f);
            pruneRenders = [];
        }

        for (f in renders) f();

        if (pruneLayers.length > 0) {
            for (layer in pruneLayers) layers.remove(layer);
            pruneLayers = [];
        }

        if (pruneOnRemoves.length > 0) {
            for (f in pruneOnRemoves) onRemoves.remove(f);
            pruneOnRemoves = [];
        }

        mouse.reset(true);
    }
}