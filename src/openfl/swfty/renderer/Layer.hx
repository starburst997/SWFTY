package openfl.swfty.renderer;

import openfl.swfty.renderer.Sprite;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Option;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

import openfl.geom.Rectangle;
import openfl.display.Tileset;
import openfl.display.BitmapData;
import openfl.display.Tilemap;
import openfl.events.Event;

class Layer extends Tilemap {

    public var swfty:Option<SWFTYType>;

    var tiles:IntMap<Int>;
    var mcs:StringMap<MovieClipType>;

    var sprites:Array<FinalSprite>;
    
    public static inline function create(width:Int, height:Int) {
        return new Layer(width, height);
    }

    public function new(width:Int, height:Int) {
        super(width, height);

        tiles = new IntMap();
        sprites = [];

        mcs = new StringMap();
        swfty = None;
    }

    public function add(sprite:Sprite) {
        sprites.push(sprite);
        addTile(sprite);
    }

    public function remove(sprite:Sprite) {
        sprites.remove(sprite);
        removeTile(sprite);
    }

    public inline function createBitmap(id:Int, og:Bool = false) {
        return DisplayBitmap.create(this, id, og);
    }

    public inline function getTile(id:Int):Int {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            -1;
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
                case Some(swfty) : Log.warn('Linkage: $linkage does not exists!');
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

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tileset, tiles, swfty) -> {
            this.tiles = tiles;
            this.tileset = tileset;
            loadSWFTY(swfty);
            onComplete();
        }, onError);
    }

    public function loadSWFTY(swfty:SWFTYType) {
        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }
        
        this.swfty = Some(swfty);

        reload();
    }

    public static function loadBytes(bytes:Bytes, onComplete:Tileset->IntMap<Int>->SWFTYType->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);
        
        if (!entries.exists('tilemap.png') || (!entries.exists('definitions.json') && !entries.exists('definitions.bin'))) {
            onError('Missing file');
            return;
        }
        
        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        
        function complete(bmpd:BitmapData) {
            var swfty = if (entries.exists('definitions.json')) {
                var jsonString = Zip.getString(entries.get('definitions.json'));
                var json:SWFTYJson = try {
                    haxe.Json.parse(jsonString);
                } catch(e:Dynamic) {
                    null;
                }
                json == null ? null : SWFTYType.fromJson(json);
            } else {
                var bytes = Zip.getBytes(entries.get('definitions.bin'));
                hxbit.Serializer.load(bytes, SWFTYType);
            }

            if (swfty == null) {
                onError('Corrupted file');
            }

            // Create tileset
            var rects = [];
            var map = new IntMap();
            for (tile in swfty.tiles) {
                map.set(tile.id, rects.length);
                rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
            }

            var tileset = new Tileset(bmpd, rects);

            trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

            onComplete(tileset, map, swfty);
        }

        #if sync
        complete(BitmapData.fromBytes(tilemapBytes));
        #else
        BitmapData.loadFromBytes(tilemapBytes).onComplete(complete).onError(e -> onError(e));
        #end
    } 
}