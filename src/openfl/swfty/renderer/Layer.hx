package openfl.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tileset;

typedef EngineContainer = openfl.display.Sprite;
typedef EngineLayer = openfl.display.Tilemap;
typedef DisplayTile = Int;

@:access(swfty.renderer.BaseSprite)
class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        // TODO: If null, it should maybe be the stage's dimensions??? Or at least on the "getter"
        super(width == null ? 256 : width, height == null ? 256 : height);

        _width = width;
        _height = height;
    }

    override function get_container() {
        if (container == null) {
            container = new EngineContainer();
            container.addChild(this);
        }
        return container;
    }

    override function get_base() {
        if (base == null) {
            base = FinalSprite.create(this);
            base._name = 'base';
            base.countVisible = false;
            addTile(base);
        }
        return base;
    }

    public override function emptyTile(?id:Int):DisplayTile {
        return -1;
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {
            swfty.addAll(bmpd.width, bmpd.height);

            // Create tileset
            var rects = [];
            tiles = new IntMap();
            for (tile in swfty.tiles) {
                tiles.set(tile.id, rects.length);
                rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
            }

            /*if (this.tileset != null) {
                this.tileset.bitmapData = bmpd;
                this.tileset.rectData = new Vector<Float>();
                for (rect in rects) this.tileset.addRect(rect);
            } else {
                var tileset = new Tileset(bmpd, rects);
                this.tileset = tileset;
            }*/

            textureMemory = bmpd.width * bmpd.height * 4;

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