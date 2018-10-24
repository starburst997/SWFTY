package openfl.swfty.renderer;

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
    
    public static inline function create(width:Int, height:Int, ?tileset) {
        return new Layer(width, height, tileset);
    }

    public static inline function createAsync(width:Int, height:Int, bytes:Bytes, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tileset, json) -> {
            var layer = create(width, height, tileset);
            layer.loadJson(json);
            onComplete(layer);
        }, onError);
    }

    public function new(width:Int, height:Int, ?tileset) {
        super(width, height, tileset);

        tiles = new IntMap();
        mcs = new StringMap();
        swfty = None;
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

    public function get(linkage:String):Sprite {
        return if (!mcs.exists(linkage)) {
            Log.warn('Linkage: $linkage does not exists!');
            Sprite.create(this, None);
        } else {
            Sprite.create(this, Some(mcs.get(linkage)));
        }
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tileset, json) -> {
            this.tileset = tileset;
            loadJson(json);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson) {
        var swfty = SWFTYType.fromJson(json);

        var i = 0;
        for (tile in swfty.tiles) {
            tiles.set(tile.id, i++);
        }

        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }

        this.swfty = Some(swfty);
    }

    public static function loadBytes(bytes:Bytes, onComplete:Tileset->SWFTYJson->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd:BitmapData) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                // Create tileset
                var i = 0;
                var rects = [];
                var map = new IntMap();
                for (tile in json.tiles) {
                    map.set(tile.id, i++);
                    rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
                }

                var tileset = new Tileset(bmpd, rects);

                trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

                onComplete(tileset, json);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        #if sync
        complete(BitmapData.fromBytes(tilemapBytes));
        #else
        BitmapData.loadFromBytes(tilemapBytes).onComplete(complete).onError(e -> onError(e));
        #end
    } 
}