package heaps.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;

import h2d.RenderContext;
import h2d.Tile;

import swfty.renderer.BaseLayer;

typedef EngineLayer = h2d.TileGroup;
typedef DisplayTile = h2d.Tile;

class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }

    public function new(?width:Int, ?height:Int) {
        super(null);
        
        // TODO: If null, it should maybe be the stage's dimensions??? Or at least on the "getter"
        _width = width;
        _height = height;
    }

    override function get_base() {
        if (base == null) {
            base = FinalSprite.create(this);
            addChild(base);
        }
        return base;
    }

    override function draw(ctx:RenderContext) {
        clear();
        @:privateAccess for (sprite in base._sprites) sprite.render(ctx);
        
        super.draw(ctx);
    }

    public override function emptyTile(?id:Int):DisplayTile {
        return null;
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(tile:h2d.Tile) {
            swfty.addAll(tile.width, tile.height);

            this.tile = tile;

            tiles = new IntMap();
            for (tile in swfty.tiles) {
                tiles.set(tile.id, this.tile.sub(tile.x, tile.y, tile.width, tile.height));
            }

            trace('Tilemap: ${tile.width}, ${tile.height}');

            if (onComplete != null) onComplete();
        }

        #if js
        // Filename is only used so the load methods knows it's a PNG
        Image.loadBytes('tilemap.png', bytes, function(image) {
            complete(image.toTile());
        });
        #else
        complete(Image.create(bytes).toTile());
        #end
    }
}