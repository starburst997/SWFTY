package heaps.swfty.renderer;

import swfty.renderer.Font;

import h2d.Tile;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

class Layer extends h2d.TileGroup {
    
    public var json:SWFTYJson;

    var ids:IntMap<MovieClipDefinition>;
    var fonts:IntMap<Font>;
    var mcs:StringMap<MovieClipDefinition>;

    public static inline function create(?tile:h2d.Tile, ?parent) {
        return new Layer(tile, parent);
    }

    public function new(?tile:h2d.Tile, ?parent) {
        super(tile, parent);

        ids = new IntMap();
        fonts = new IntMap();
        mcs = new StringMap();
    }

    public inline function getFont(id:Int) {
        return fonts.get(id);
    }

    public inline function hasFont(id:Int) {
        return fonts.exists(id);
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
        loadBytes(bytes, (tile, json) -> {
            this.tile = tile;
            loadJson(json);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson) {
        add(0, 0, new Tile(tile.getTexture(), 0, 0, 500, 500));
    }

    public static function createAsync(bytes:Bytes, ?parent, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tile, json) -> {
            var layer = create(tile, parent);
            layer.loadJson(json);
            onComplete(layer);
        }, onError);
    }

    public static function loadBytes(bytes:Bytes, onComplete:h2d.Tile->SWFTYJson->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(tile:h2d.Tile) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                trace('Tilemap: ${tile.width}, ${tile.height}');

                onComplete(tile, json);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        complete(Image.create(tilemapBytes).toTile());
    }
}