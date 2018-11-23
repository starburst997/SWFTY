package swfty.renderer;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Option;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

enum ButtonState {
    Down;
    Up;
    Normal;
}

class Mouse {
    public var x:Float = 0.0;
    public var y:Float = 0.0;
    
    public var leftChanged:Bool = false;
    public var middleChanged:Bool = false;
    public var rightChanged:Bool = false;

    public var left(default, set):ButtonState = Normal;
    public var middle(default, set):ButtonState = Normal;
    public var right(default, set):ButtonState = Normal;

    public function new() {

    }

    inline function set_left(state:ButtonState) {
        left = state;
        leftChanged = true;
        return state;
    }

    inline function set_middle(state:ButtonState) {
        middle = state;
        middleChanged = true;
        return state;
    }

    inline function set_right(state:ButtonState) {
        right = state;
        rightChanged = true;
        return state;
    }

    public inline function reset() {
        switch(left) {
            case Up : left = Normal;
            case _  :
        }
        switch(middle) {
            case Up : middle = Normal;
            case _  :
        }
        switch(right) {
            case Up : right = Normal;
            case _  :
        }

        leftChanged = false;
        rightChanged = false;
        middleChanged = false;
    }
}

class BaseLayer extends EngineLayer {

    var disposed = false;

    public var swfty:Option<SWFTYType> = None;

    // Mouse need to be updated from the engine
    public var mouse = new Mouse();

    var tiles:IntMap<DisplayTile> = new IntMap();
    var mcs:StringMap<MovieClipType> = new StringMap();

    var renders:Array<Float->Void> = [];
    var mouseDowns:Array<Float->Float->Void> = [];
    var mouseUps:Array<Float->Float->Void> = [];

    public var base(get, null):FinalSprite;
    function get_base() {
        if (base == null) base = FinalSprite.create(this);
        return base;
    }

    public function update(dt:Float) {
        for (f in renders) f(dt);
        
        if (mouse.leftChanged) {
            var y = mouse.y;
            var x = mouse.x;

            switch(mouse.left) {
                case Down : for (f in mouseDowns) f(x, y);
                case Up   : for (f in mouseUps) f(x, y);
                case _    : 
            }
        }

        base.update(dt);

        // Reset mouse properties
        mouse.reset();
    }

    public function addRender(f:Float->Void) {
        renders.push(f);
    }

    public function removeRender(f:Float->Void) {
        renders.remove(f);
    }

    public function addMouseDown(f:Float->Float->Void) {
        mouseDowns.push(f);
    }

    public function removeMouseDown(f:Float->Float->Void) {
        mouseDowns.remove(f);
    }

    public function addMouseUp(f:Float->Float->Void) {
        mouseUps.push(f);
    }

    public function removeMouseUp(f:Float->Float->Void) {
        mouseUps.remove(f);
    }

    public function addSprite(sprite:Sprite) {
        base.addSprite(sprite);
    }

    public function removeSprite(sprite:Sprite) {
        base.removeSprite(sprite);
    }

    public inline function createBitmap(id:Int, og:Bool = false) {
        return DisplayBitmap.create(this, id, og);
    }

    public function emptyTile():DisplayTile {
        throw 'Not implemented';
    }

    public inline function getTile(id:Int):DisplayTile {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            var tile = emptyTile();
            tiles.set(id, tile);
            tile;
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

    public inline function empty() {
        return Sprite.create(this);
    }

    public function get(linkage:String) {
        return if (!mcs.exists(linkage)) {
            switch(swfty) {
                case Some(_) : Log.warn('Linkage: $linkage does not exists!');
                case None : 
            }
            Sprite.create(this, linkage);
        } else {
            Sprite.create(this, mcs.get(linkage));
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
            Log.warn('ID: $id does not exists!');
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
        
        this.swfty = Some(swfty);
    }

    public function loadBytes(bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        if (disposed) {
            if (onError != null) onError('Layer was disposed');
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
            hxbit.Serializer.load(bytes, SWFTYType);
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

    public function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        throw 'Not implemented';
    }

    public function dispose() {
        if (!disposed) {
            disposed = true;

            renders = [];
            mouseDowns = [];
            mouseUps = [];

            swfty = None;
            tiles = new IntMap();
            mcs = new StringMap();

            base.dispose();
            base = null;
        }
    }
}