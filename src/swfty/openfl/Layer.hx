package swfty.openfl;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

import openfl.geom.Rectangle;
import openfl.display.Tileset;
import openfl.display.BitmapData;
import openfl.display.Tilemap;
import openfl.events.Event;

class Layer extends Tilemap {

    var afterFrames:Array<Void->Void> = [];

    var tiles:IntMap<Int>;
    var ids:IntMap<MovieClipDefinition>;
    var mcs:StringMap<MovieClipDefinition>;

    public static inline function create(width:Int, height:Int, ?tileset) {
        return new Layer(width, height, tileset);
    }

    public static inline function createAsync(width:Int, height:Int, bytes:Bytes, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadTileset(bytes, (tileset, json) -> {
            var layer = create(width, height, tileset);
            layer.loadJson(json);
            onComplete(layer);
        }, onError);
    }

    public function new(width:Int, height:Int, ?tileset) {
        super(width, height, tileset);

        tiles = new IntMap();
        ids = new IntMap();
        mcs = new StringMap();

        /*addEventListener(Event.ENTER_FRAME, render);

        #if html5
        // Weird OpenFL html5 bug with tilemap...
        afterFrame(() -> {
            x += 0.00000001;
            afterFrame(() -> {
                x -= 0.00000001;
            });
        });
        #end*/
    }

    public function dispose() {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    inline function afterFrame(f:Void->Void) {
        afterFrames.push(f);
    }

    function render(e) {
        if (afterFrames.length > 0) {
            var copy = [for (f in afterFrames) f];
            afterFrames = [];

            for (f in copy) f();
        }
    }

    public inline function getTile(id:Int):Int {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            -1;
        } 
    }

    public inline function getDefinition(id:Int):MovieClipDefinition {
        return ids.get(id);
    }

    public inline function hasDefinition(id:Int):Bool {
        return ids.exists(id);
    }

    public inline function getAllNames() {
        return [for (key in mcs.keys()) key];
    }

    public function resize(width:Int, height:Int) {

    }

    public function get(linkage:String):Sprite {
        return if (!mcs.exists(linkage)) {
            Log.warn('Linkage: $linkage does not exists!');
            Sprite.create(this);
        } else {
            var sprite = Sprite.create(this, mcs.get(linkage));
            sprite;
        }
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Dynamic->Void) {
        loadTileset(bytes, (tileset, json) -> {
            this.tileset = tileset;
            loadJson(json);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson) {
        for (i in 0...json.tiles.length) {
            var tile = json.tiles[i];
            tiles.set(tile.id, i);
        }

        for (definition in json.definitions) {
            if (definition.name != null) mcs.set(definition.name, definition);
            ids.set(definition.id, definition);
        }
    }

    public static function loadTileset(bytes:Bytes, onComplete:Tileset->SWFTYJson->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                // Create tileset
                var rects = [];
                for (tile in json.tiles) {
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