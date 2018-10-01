
import haxe.io.Bytes;

import SWFTYExporter;

import zip.Zip;
import zip.ZipReader;
import zip.ZipEntry;

import openfl.display.BitmapData;
import openfl.display.TileContainer;
import openfl.display.Tilemap;

class SWFTYLayer extends Tilemap {

    public static inline function create(width:Int, height:Int) {
        return new SWFTYLayer(width, height);
    }

    public function new(width:Int, height:Int) {
        super(width, height);
    }

    public function resize(width:Int, height:Int) {

    }

    public function add(linkage:String):SWFTYSprite {
        return SWFTYSprite.create();
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Void->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd) {
            try {
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                trace(bmpd.width, bmpd.height, json);

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