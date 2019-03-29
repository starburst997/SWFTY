package openfl_list.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

typedef EngineContainer = openfl.display.Sprite;
typedef EngineLayer = openfl.display.Sprite;
typedef DisplayTile = openfl.display.BitmapData;

@:access(swfty.renderer.BaseSprite)
class FinalLayer extends BaseLayer {

    var texture:BitmapData;
    var rects:IntMap<Rectangle> = new IntMap();

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        // TODO: If null, it should maybe be the stage's dimensions??? Or at least on the "getter"
        super();

        _width = width;
        _height = height;
    }

    override function get_container() {
        if (container == null) {
            trace('++++ CREATE LAYER');
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
            addChild(base);
        }
        return base;
    }

    override function hasParent():Bool {
        return container.parent != null;
    }

    public override function emptyTile(?id:Int):DisplayTile {
        return if (id != null && texture != null && rects.exists(id)) {
            var rect = rects.get(id);

            if (Std.int(rect.width) > 0 && Std.int(rect.height) > 0) {
                var bmpd = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x00000000);
                bmpd.copyPixels(texture, rect, new Point(0, 0));
                bmpd;
            } else {
                new BitmapData(1, 1, true, 0x00000000);
            }
        } else {
            new DisplayTile(1, 1, true, 0x00000000);
        }
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {
            swfty.addAll(bmpd.width, bmpd.height);

            tiles = new IntMap();
            for (tile in swfty.tiles) {
                rects.set(tile.id, new Rectangle(tile.x, tile.y, tile.width, tile.height));
            }

            texture = bmpd;
            textureMemory = bmpd.width * bmpd.height * 4;

            trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

            if (onComplete != null) onComplete();
        }

        #if sync
        complete(BitmapData.fromBytes(bytes));
        #else
        BitmapData.loadFromBytes(bytes).onComplete(complete).onError(onError);
        #end
    }

    public override function dispose() {
        if (!disposed) {
            // Never too prudent, immediately dispose of all bitmap data associated with this layer
            if (texture != null) texture.dispose();
            for (tile in tiles) {
                tile.dispose();
            }
            tiles = new IntMap();
        }

        super.dispose();
    }
}