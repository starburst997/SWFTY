package swfty.renderer;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Option;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

import binpacking.Rect;
import binpacking.SimplifiedMaxRectsPacker;

@:access(swfty.renderer.BaseSprite)
class BaseLayer extends EngineLayer {

    public static var baseID = 0;

    public var disposed = false;

    // TODO: Should be enough? Maybe save the max id in SWFTY?
    var customId = 1000000;
    var maskId = 2000000;

    var _width:Int = 1;
    var _height:Int = 1;
    
    // The layer will be added as a child of this container and used when mixing layer together
    @:isVar public var container(get, null):EngineContainer;
    function get_container() {
        trace('!! OVERRIDE ME get_container()');
        if (container == null) {
            container = new EngineContainer();
        }
        return container;
    }

    var _mask(default, set):Rectangle = null;
    function set__mask(value:Rectangle) {
        _mask = value;
        return value;
    }

    @:isVar public var reserved(get, null):Rectangle;
    inline function get_reserved() {
        if (reserved == null) {
            reserved = getReservedSpace();
        }
        return reserved;
    }

    public var time:Float = 0;

    public var sleeping = false;
    public var hasVisible = false;
    public var loaded = false;
    public var updating = false;
    public var canDispose = false;

    public var id = '';

    public var path:String = '';

    public var textureMemory:Int = 0;

    public var swfty:Option<SWFTYType> = None;

    public var shared:Shared = {};
    var cancelInteract = false;

    public var renderID = 0;
    public var spriteRenderID = 0;

    public var parentLayer:Layer = null;
    var layers:Array<Layer> = [];
    var pruneLayers:Array<Layer> = [];

    public var debug = false;

    // Mouse need to be updated from the engine
    public var mouse = new Mouse();

    var tiles:IntMap<DisplayTile> = new IntMap();
    var mcs:StringMap<MovieClipType> = new StringMap();

    var customTiles:StringMap<CustomTile> = new StringMap();
    var packer:SimplifiedMaxRectsPacker = null;
    var removedFromReservedSpace = false;

    var wakes:Array<Void->Void> = [];
    var sleeps:Array<Void->Void> = [];
    var renders:Array<Float->Void> = [];
    var postRenders:Array<Float->Void> = [];
    var mouseDowns:Array<Float->Float->Void> = [];
    var mouseUps:Array<Float->Float->Void> = [];

    var pruneWakes:Array<Void->Void> = [];
    var pruneSleeps:Array<Void->Void> = [];
    var pruneRenders:Array<Float->Void> = [];
    var prunePostRenders:Array<Float->Void> = [];
    var pruneMouseDowns:Array<Float->Float->Void> = [];
    var pruneMouseUps:Array<Float->Float->Void> = [];

    public var pause(get, set):Bool;
    inline function set_pause(value:Bool):Bool {
        return shared.pause = value;
    }
    inline function get_pause():Bool {
        return shared.pause;
    }

    public var canInteract(get, set):Bool;
    inline function set_canInteract(value:Bool):Bool {
        return shared.canInteract = value;
    }
    inline function get_canInteract():Bool {
        return shared.canInteract;
    }

    public var _scale(get, set):Float;
    inline function get__scale() {
        return this.base.scaleX;
    }
    inline function set__scale(value:Float) {
        this.base.scaleX = this.base.scaleY = value;
        return value;
    }

    public var screenWidth(get, null):Float;
    inline function get_screenWidth() {
        return _width / this.base.scaleX;
    }

    public var screenHeight(get, null):Float;
    inline function get_screenHeight() {
        return _height / this.base.scaleY;
    }

    // TODO: Disable all transform on this object, should be equivalent to "stage" in Flash
    //       Create StageSprite or RootSprite, only a container with no matrix or position
    public var base(get, null):FinalSprite;
    function get_base() {
        if (base == null) {
            base = FinalSprite.create(this);
            base._name = 'base';
            base.countVisible = false;
        }
        return base;
    }

    // TODO: Not sure if I should only have a "base" and no "baseLayout" 
    //       but it's nice to have an "un-transformed" Sprite as the root
    public var baseLayout(get, null):FinalSprite;
    function get_baseLayout() {
        if (baseLayout == null) {
            baseLayout = FinalSprite.create(this);
            baseLayout._name = 'baseLayout';
            baseLayout.countVisible = false;
            base.addSprite(baseLayout);
        }
        return baseLayout;
    }

    public function wake() {
        if (sleeping) {
            sleeping = false;

            // TODO: Re-add to display list?

            for (f in wakes) f();
        }
    }

    public function sleep() {
        if (!sleeping) {
            sleeping = true;

            // TODO: Remove from display list?

            for (f in sleeps) f();
        }
    }

    public function getReservedSpace():Rectangle {
        return switch(swfty) {
            case Some(swfty) if (swfty.tiles.exists(swfty.reserved_space)) : 
                var tile = swfty.tiles.get(swfty.reserved_space);
                {
                    x: tile.x,
                    y: tile.y,
                    width: tile.width,
                    height: tile.height
                }
            case _ : {
                x: 0, 
                y: 0,
                width: 1,
                height: 1
            }
        }
    }

    // TODO: Add individual mouseX / mouseY on Sprite object instead
    public inline function getMouseX() {
        return (mouse.x - baseLayout.x) / baseLayout.scaleX;
    }

    public inline function getMouseY() {
        return (mouse.y - baseLayout.y) / baseLayout.scaleY;
    }

    public function localToLayer(x:Float = 0.0, y:Float = 0.0):Point {
        throw 'Not implemented';
    }

    public function layerToLocal(x:Float, y:Float):Point {
        throw 'Not implemented';
    }

    public function calculateRenderID() {
        for (i in 0...layers.length) {
            var layer = layers[layers.length - i - 1];
            layer.calculateRenderID();
        }

        renderID = BaseLayer.baseID++;
    }

    public inline function offset(x:Float, y:Float) {
        base.x = x; // / base.scaleX;
        base.y = y; // / base.scaleY;
    }

    public function update(dt:Float) {
        if (pause || sleeping) return;

        updating = true;
        hasVisible = false;

        time = haxe.Timer.stamp() * 1000;

        if (pruneRenders.length > 0) {
            for (f in pruneRenders) renders.remove(f);
            pruneRenders = [];
        }

        for (f in renders) if (!canDispose) f(dt);
        
        if (pruneMouseDowns.length > 0) {
            for (f in pruneMouseDowns) mouseDowns.remove(f);
            pruneMouseDowns = [];
        }
        
        if (pruneMouseUps.length > 0) {
            for (f in pruneMouseUps) mouseUps.remove(f);
            pruneMouseUps = [];
        }

        if (mouse.leftChanged) {
            var y = mouse.y;
            var x = mouse.x;

            switch(mouse.left) {
                case Down : for (f in mouseDowns) if (!canDispose) f(x, y);
                case Up   : for (f in mouseUps) if (!canDispose) f(x, y);
                case _    : 
            }
        }

        spriteRenderID = 0;
        if (!canDispose) base.update(dt);

        if (prunePostRenders.length > 0) {
            for (f in prunePostRenders) postRenders.remove(f);
            prunePostRenders = [];
        }

        for (f in postRenders) if (!canDispose) f(dt);

        if (pruneWakes.length > 0) {
            for (f in pruneWakes) wakes.remove(f);
            pruneWakes = [];
        }

        if (pruneSleeps.length > 0) {
            for (f in pruneSleeps) sleeps.remove(f);
            pruneSleeps = [];
        }

        if (pruneLayers.length > 0) {
            for (f in pruneLayers) layers.remove(f);
            pruneLayers = [];
        }

        // Reset mouse properties
        mouse.reset();

        if (!hasVisible) sleep();

        updating = false;

        if (canDispose) {
            canDispose = false;
            dispose();
        }
    }

    public inline function removeAll() {
        baseLayout.removeAll();
    }

    public inline function addWake(f:Void->Void) {
        wakes.push(f);
    }
    

    public inline function addSleep(f:Void->Void) {
        sleeps.push(f);
    }

    public inline function addRender(f:Float->Void, ?priority = false) {
        if (priority) renders.unshift(f);
        else renders.push(f);
    }

    public inline function addPostRender(f:Float->Void, ?priority = false) {
        if (priority) postRenders.unshift(f);
        else postRenders.push(f);
    }

    public inline function addPostRenderNow(f:Float->Void, ?priority = false) {
        addPostRender(f, priority);
        f(0.0);
    }

    public inline function addRenderNow(f:Float->Void, ?priority = false) {
        addRender(f, priority);
        f(0.0);
    }

    public inline function removeWake(f:Void->Void) {
        pruneWakes.push(f);
    }

    public inline function removeSleep(f:Void->Void) {
        pruneSleeps.push(f);
    }

    public inline function removeRender(f:Float->Void) {
        pruneRenders.push(f);
    }

    public inline function removePostRender(f:Float->Void) {
        prunePostRenders.push(f);
    }

    public inline function addMouseDown(f:Float->Float->Void, ?priority = false) {
        if (priority) mouseDowns.unshift(f); 
        else mouseDowns.push(f);
    }

    public inline function removeMouseDown(f:Float->Float->Void) {
        pruneMouseDowns.push(f);
    }

    public inline function addMouseUp(f:Float->Float->Void, ?priority = false) {
        if (priority) mouseUps.unshift(f); 
        else mouseUps.push(f);
    }

    public inline function removeMouseUp(f:Float->Float->Void) {
        pruneMouseUps.push(f);
    }

    public inline function addSprite(sprite:Sprite) {
        baseLayout.addSprite(sprite);
    }

    public inline function addSpriteAt(sprite:Sprite, index:Int = 0) {
        baseLayout.addSpriteAt(sprite, index);
    }

    public inline function removeSprite(sprite:Sprite) {
        baseLayout.removeSprite(sprite);
    }

    public inline function createBitmap(id:Int, og:Bool = false) {
        return DisplayBitmap.create(this, id, og);
    }

    public function addLayer(layer:Layer) {
        layers.push(layer);
        layer.parentLayer = this;
    }

    public function addLayerAt(layer:Layer, index:Int) {
        layers.insert(index, layer);
        layer.parentLayer = this;
    }

    public function removeLayer(layer:Layer) {
        pruneLayers.push(layer);
        layer.parentLayer = null;
    }

    public function emptyTile(?id:Int):DisplayTile {
        throw 'Not implemented';
    }

    public function hasParent():Bool {
        throw 'Not implemented';
    }

    public function getIndex():Int {
        throw 'Not implemented';
    }

    public inline function getTile(id:Int):DisplayTile {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            #if (!openfl || !list)
            Log.warn('Missing shape: $id');
            #end
            var tile = emptyTile(id);
            tiles.set(id, tile);
            tile;
        } 
    }

    public inline function addCustomTile(tile:DisplayTile) {
        var id = ++customId;
        tiles.set(id, tile);
        return id;
    }

    public function createCustomTile(x:Int, y:Int, width:Int, height:Int):DisplayTile {
        throw 'Not implemented';
    }

    public function updateDisplayTile(id:DisplayTile, x:Int, y:Int, width:Int, height:Int) {
        throw 'Not implemented';
    }

    public function redrawReservedSpace(map:Map<CustomTile, Rect>) {
        throw 'Not implemented';
    }

    public function drawCustomTile(tile:CustomTile, rect:binpacking.Rect) {
        throw 'Not implemented';
    }

    public inline function getInternalScale():Float {
        return switch(swfty) {
            case Some(swfty) : swfty.tilemap_scale;
            case None : 1.0;
        }
    }

    public inline function getFont(id:Int):FontType {
        return switch(swfty) {
            case Some(swfty) : swfty.fonts.get(id);
            case None : null;
        }
    }

    public inline function hasFont(id:Int) {
        return switch(swfty) {
            case Some(swfty) : swfty.fonts.exists(id);
            case None : false;
        }
    }

    public inline function getDefinition(id:Int):MovieClipType {
        return switch(swfty) {
            case Some(swfty) : swfty.definitions.get(id);
            case None : null;
        }
    }

    public inline function hasDefinition(id:Int):Bool {
        return switch(swfty) {
            case Some(swfty) : swfty.definitions.exists(id);
            case None : false;
        }
    }

    public inline function getAllNames() {
        return [for (key in mcs.keys()) key];
    }

    public function resize(width:Int, height:Int) {
        
    }

    public inline function empty(add:Bool = false) {
        var sprite = Sprite.create(this);
        sprite.loaded = true;
        if (add) baseLayout.addSprite(sprite);
        return sprite;
    }

    public function get(linkage:String, debug = false) {
        return if (!mcs.exists(linkage)) {
            switch(swfty) {
                case Some(_) : Log.warn('Linkage: $linkage does not exists! ${path}');
                case None : 
            }
            Sprite.create(this, linkage, debug);
        } else {
            Sprite.create(this, mcs.get(linkage), linkage, debug);
        }
    }

    public inline function getMC(linkage:String):MovieClipType {
        return mcs.get(linkage);
    }

    public inline function hasMC(linkage:String) {
        return mcs.exists(linkage);
    }

    public function getById(id:Int) {
        return if (!hasDefinition(id)) {
            Log.warn('ID: $id does not exists! ${path}');
            Sprite.create(this);
        } else {
            Sprite.create(this, getDefinition(id));
        }
    }

    public function reload() {
        base.reload();
    }

    public function loadSWFTY(swfty:SWFTYType) {
        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }
        
        loaded = true;
        this.swfty = Some(swfty);
        this.id = swfty.name;
    }

    // Load a single image into a layer
    // The Sprite you can create from this layer is called "All"
    public function loadImage(bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        if (bytes == null) trace('Warning loading empty bytes SWFTY (${path})');
        
        var swfty:SWFTYType = {
            name: 'no-name-${bytes == null ? 0 : bytes.length}',
            tilemap_width: 0,
            tilemap_height: 0,
            tilemap_scale: 1,
            definitions: new IntMap(),
            tiles: new IntMap(),
            fonts: new IntMap()
        };

        if (bytes == null) {
            // Empty layer... (something wrong happens, but better to show nothing than crash...)
            if (disposed) return;

            loadSWFTY(swfty);
            reload();
            
            if (onComplete != null) onComplete();
        } else {
            loadTexture(bytes, swfty, function() {
                if (disposed) return;

                loadSWFTY(swfty);
                reload();

                if (onComplete != null) onComplete();
            }, function(e) {
                if (disposed) return;
                
                if (onError != null) onError(e);
            });
        }
    }

    // Load SWFTY file format
    public function loadBytes(bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        if (disposed) {
            if (onError != null) onError('Layer was disposed');
            return;
        }

        if (bytes == null) {
            if (onError != null) onError('Bytes are null');
            return;
        }

        var TILEMAP_PNG     = 'tilemap.png';
        var DEFINITION_JSON = 'definitions.json';
        var DEFINITION_BIN  = 'definitions.bin';
        
        var entries = ZipReader.getEntries(bytes);
        
        if (!entries.exists(TILEMAP_PNG) || (!entries.exists(DEFINITION_JSON) && !entries.exists(DEFINITION_BIN))) {
            if (onError != null) onError('Missing file');
            return;
        }
        
        var swfty = if (entries.exists(DEFINITION_JSON)) {
            var jsonString = Zip.getString(entries.get(DEFINITION_JSON));
            var json:SWFTYJson = try {
                haxe.Json.parse(jsonString);
            } catch(e:Dynamic) {
                null;
            }
            json == null ? null : SWFTYType.fromJson(json);
        } else {
            var bytes = Zip.getBytes(entries.get(DEFINITION_BIN));
            #if !macro
            hxbit.Serializer.load(bytes, SWFTYType);
            #else
            // TODO: Currently unavailable in macro, issue with hxbit or something?
            null;
            #end
        }

        if (swfty == null) {
            if (onError != null) onError('Corrupted file');
            return;
        }

        var tilemapBytes = Zip.getBytes(entries.get(TILEMAP_PNG));
        loadTexture(tilemapBytes, swfty, function() {
            if (disposed) return;

            loadSWFTY(swfty);
            reload();
            if (onComplete != null) onComplete();
        }, function(e) {
            if (disposed) return;
            
            if (onError != null) onError(e);
        });
    }

    public inline function hasPath(path:String) {
        return customTiles.exists(path);
    }

    // Draw an image specified by path onto the texture
    public function drawPath(path:String, width:Int = 1, height:Int = 1) {
        if (customTiles.exists(path)) {
            var tile = customTiles.get(path);
            tile.counter++;
            
            return tile;
        } else if (reserved.empty()) {
            trace('Warning no reserved space for ${this.path}');

            // Create empty tile
            var tile:CustomTile = {
                path: path,
                x: 0,
                y: 0,
                width: width,
                height: height,
                originalWidth: width,
                originalHeight: height
            };

            customTiles.set(path, tile);

            tile.tile = emptyTile();
            tile.id = addCustomTile(tile.tile);
            return tile;

        } else {
            // Try to fit
            if (packer == null) {
                packer = new SimplifiedMaxRectsPacker(reserved.width, reserved.height);
            }

            var padding = 1;
            var rect = packer.insert(width + padding * 2, height + padding * 2);

            if (rect == null) {
                // Create the custom tile and add it using dummy data
                var tile:CustomTile = {
                    path: path,
                    x: 0,
                    y: 0,
                    width: width,
                    height: height,
                    originalWidth: width,
                    originalHeight: height
                };

                customTiles.set(path, tile);

                var sortedTiles = customTiles.array();
                sortedTiles.sortdf(function(tile) return tile.width * tile.height);

                // We've hit the limit! Need to re-organize reserved space
                var packer = new SimplifiedMaxRectsPacker(reserved.width, reserved.height);

                function tryFitAll(scale = 1.0) {
                    var map:Map<CustomTile, Rect> = new Map();

                    for (tile in sortedTiles) {
                        var s = tile.scale < scale ? tile.scale : scale;

                        var rect = packer.insert(Std.int(tile.originalWidth * s) + padding * 2, Std.int(tile.originalHeight * s) + padding * 2);
                        if (rect == null) {
                            return null;
                        } else {
                            map.set(tile, rect);
                        }
                    }

                    for (tile in sortedTiles) {
                        if (tile.scale > scale) {
                            tile.scale = scale;
                        }
                    }

                    // Redraw all and save info
                    redrawReservedSpace(map);

                    return map;
                }

                // We had stuff removed, we might be able to fit everything again!
                if (removedFromReservedSpace) {
                    removedFromReservedSpace = false;

                    var rects = tryFitAll();
                    if (rects != null) {
                        // Good we were able to re-fit everything!
                        // Save this packer for re-use and return tile
                        this.packer = packer;
                        return tile;
                    }
                }

                // Alright, seems like we have too much stuff, try to fit everything by scaling down
                var scale = 1.0;
                while ((scale -= 0.05) > 0.1) {
                    packer = new SimplifiedMaxRectsPacker(reserved.width, reserved.height);
                    var rects = tryFitAll(scale);
                    if (rects != null) {
                        // Good we were able to re-fit everything by scaling down!
                        // Save this packer for re-use and return tile
                        this.packer = packer;
                        return tile;
                    }
                }

                // We can't fit, the tile will look empty...
                tile.tile = emptyTile();
                tile.id = addCustomTile(tile.tile);

                return tile;
            } else {
                // Nice it fits!
                var tile:CustomTile = {
                    path: path,
                    x: Std.int(rect.x) + padding,
                    y: Std.int(rect.y) + padding,
                    width: Std.int(rect.width) - padding*2,
                    height: Std.int(rect.height) - padding*2,
                    originalWidth: Std.int(rect.width) - padding*2,
                    originalHeight: Std.int(rect.height) - padding*2
                };
                customTiles.set(path, tile);
                
                drawCustomTile(tile, rect);

                return tile;
            }
        }
    }

    // Mark an image speificed by path as unused
    public function removePath(path:String) {
        if (customTiles.exists(path)) {
            if (--customTiles.get(path).counter <= 0) {
                customTiles.remove(path);
                removedFromReservedSpace = true;
            }
        }
    }

    public function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        throw 'Not implemented';
    }

    public function dispose() {
        if (!disposed) {
            if (!updating) {
                disposed = true;

                layers = [];
                renders = [];
                mouseDowns = [];
                mouseUps = [];
                wakes = [];
                sleeps = [];
                
                pruneLayers = [];
                pruneWakes = [];
                pruneSleeps = [];
                pruneRenders = [];
                pruneMouseDowns = [];
                pruneMouseUps = [];

                swfty = None;
                tiles = new IntMap();
                mcs = new StringMap();

                if (parentLayer != null) {
                    parentLayer.removeLayer(this);
                    parentLayer = null;
                }

                baseLayout.dispose();
                baseLayout = null;

                base.dispose();
                base = null;
            } else {
                canDispose = true;
            }
        }
    }
}

@:structInit
class Shared {
    public var canInteract = true;
    public var pause = false;

    public function new(?canInteract:Bool = true, ?pause:Bool = false) {
        this.canInteract = canInteract;
        this.pause = pause;
    }
}

@:structInit
class CustomTile {
    public var id = -1;
    public var path = '';
    public var counter = 1;
    public var scale = 1.0;
    public var x = 0;
    public var y = 0;
    public var width = 1;
    public var height = 1;
    public var originalWidth = 1;
    public var originalHeight = 1;
    public var tile:DisplayTile;
    public var isDrawn = false;

    public function new(?path:String = '', ?id:Int = -1, ?counter:Int = 1, ?scale:Float = 1.0, ?x:Int = 0, ?y:Int = 0, ?width:Int = 1, ?height:Int = 1, ?originalWidth:Int = 1, ?originalHeight:Int = 1, ?tile:DisplayTile) {
        this.path = path;
        this.id = id;
        this.counter = counter;
        this.scale = scale;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.originalWidth = originalWidth;
        this.originalHeight = originalHeight;
        this.tile = tile;
    }
}