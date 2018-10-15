package heaps.swfty.renderer;

import haxe.ds.IntMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

class Layer extends h2d.TileGroup {
    
    public static inline function create(?tile:h2d.Tile, ?parent) {
        return new Layer(tile, parent);
    }

    public function new(?tile:h2d.Tile, ?parent) {
        super(tile, parent);

        
    }

    public function loadJson(json:SWFTYJson) {
        
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

        function complete() {
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
                    //rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
                }

                /*var tileset = new Tileset(bmpd, rects);

                trace('Tilemap: ${bmpd.width}, ${bmpd.height}');*/

                onComplete(null, json);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        // TODO: Load bitmapdata
        complete();
    }
}