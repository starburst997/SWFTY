package swfty.renderer;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Option;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

class BaseLayer extends EngineLayer {

    public var swfty:Option<SWFTYType> = None;

    var tiles:IntMap<DisplayTile> = new IntMap();
    var mcs:StringMap<MovieClipType> = new StringMap();

    var sprites:Array<FinalSprite> = [];
    var pruneSprites:Array<FinalSprite> = [];

    public function update(dt:Float) {
        for (sprite in sprites) sprite.update(dt);
        
        while(pruneSprites.length > 0) sprites.remove(pruneSprites.pop());
    }

    public function addSprite(sprite:Sprite) {
        sprites.push(sprite);
    }

    public function removeSprite(sprite:Sprite) {
        pruneSprites.push(sprite);
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

    public function empty() {
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
        for (sprite in sprites) sprite.reload();
    }

    public function loadSWFTY(swfty:SWFTYType) {
        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }
        
        this.swfty = Some(swfty);
    }

    public function loadBytes(bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
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
            loadSWFTY(swfty);
            reload();
            if (onComplete != null) onComplete();
        }, onError);
    }

    public function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        throw 'Not implemented';
    }
}