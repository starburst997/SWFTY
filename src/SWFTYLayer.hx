
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import SWFTYExporter;

import zip.Zip;
import zip.ZipReader;
import zip.ZipEntry;

import openfl.geom.Rectangle;
import openfl.display.Tileset;
import openfl.display.BitmapData;
import openfl.display.TileContainer;
import openfl.display.Tilemap;

using Lambda;

class SWFTYLayer extends Tilemap {

    var tiles:IntMap<Int>;
    var ids:IntMap<MovieClipDefinition>;
    var mcs:StringMap<MovieClipDefinition>;

    public static inline function create(width:Int, height:Int) {
        return new SWFTYLayer(width, height);
    }

    public function new(width:Int, height:Int) {
        super(width, height);

        tiles = new IntMap();
        ids = new IntMap();
        mcs = new StringMap();
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

    public function get(linkage:String):SWFTYSprite {
        return if (!mcs.exists(linkage)) {
            Log.warn('Linkage: $linkage does not exists!');
            SWFTYSprite.create(this);
        } else {
            var sprite = SWFTYSprite.create(this, mcs.get(linkage));
            sprite;
        }
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Void->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd) {
            try {
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                // Create tileset
                var rects = [];
                for (tile in json.tiles) {
                    var id = rects.length;
                    tiles.set(tile.id, id);
                    rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
                }

                tileset = new Tileset(bmpd, rects);

                for (definition in json.definitions) {
                    if (definition.name != null) mcs.set(definition.name, definition);
                    ids.set(definition.id, definition);
                }

                onComplete();
            } catch(e:Dynamic) {
                onError();
            }
        }

        #if sync
        complete(BitmapData.fromBytes(tilemapBytes));
        #else
        BitmapData.loadFromBytes(tilemapBytes).onComplete(complete).onError(e -> onError());
        #end
    }
}