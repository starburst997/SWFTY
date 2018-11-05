package openfl.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tileset;

typedef EngineLayer = openfl.display.Tilemap;
typedef DisplayTile = Int;

class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        super(width == null ? 256 : width, height == null ? 256 : height);
    }

    public override function addSprite(sprite:Sprite) {
        super.addSprite(sprite);
        addTile(sprite);
    }

    public override function removeSprite(sprite:Sprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    public override function emptyTile():DisplayTile {
        return -1;
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {
            // Create tileset
            var rects = [];
            tiles = new IntMap();
            for (tile in swfty.tiles) {
                tiles.set(tile.id, rects.length);
                rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
            }

            var tileset = new Tileset(bmpd, rects);

            this.tileset = tileset;

            trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

            if (onComplete != null) onComplete();
        }

        #if sync
        complete(BitmapData.fromBytes(bytes));
        #else
        BitmapData.loadFromBytes(bytes).onComplete(complete).onError(onError);
        #end
    }
}