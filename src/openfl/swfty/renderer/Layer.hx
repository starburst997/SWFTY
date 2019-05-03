package openfl.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

import openfl.display.BitmapData;
import openfl.display.Tileset;

typedef EngineContainer = openfl.display.Sprite;
typedef EngineLayer = openfl.display.Tilemap;
typedef DisplayTile = Int;

@:access(swfty.renderer.BaseSprite)
class FinalLayer extends BaseLayer {

    static var pt = new openfl.geom.Point();

    var pending:StringMap<BitmapData> = new StringMap();

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }

    public function new(?width:Int, ?height:Int) {
        // TODO: If null, it should maybe be the stage's dimensions??? Or at least on the "getter"
        super(width == null ? 256 : width, height == null ? 256 : height);

        _width = width;
        _height = height;
    }

    override function set__mask(value:Rectangle) {
        if (value == null) return null;

        container.scrollRect = new openfl.geom.Rectangle(value.x, value.y, value.width, value.height);
        return super.set__mask(value);
    }

    override function addLayer(layer:Layer) {
        super.addLayer(layer);
        
        container.addChild(layer.container);
    }

    override function addLayerAt(layer:Layer, index:Int) {
        super.addLayerAt(layer, index);
        
        container.addChildAt(layer.container, index);
    }

    override function removeLayer(layer:Layer) {
        super.removeLayer(layer);
        if (layer.container.parent != null) layer.container.parent.removeChild(layer.container);
    }

    override function get_container() {
        if (container == null) {
            container = new EngineContainer();
            container.name = 'Container';
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

    override function hasParent():Bool {
        return container.parent != null;
    }

    override function emptyTile(?id:Int):DisplayTile {
        return -1;
    }

    override function getIndex():Int {
        return if (this.parent == container) {
            container.getChildIndex(this);
        } else {
            container.numChildren;
        }
    }

    override function localToLayer(x:Float = 0.0, y:Float = 0.0):Point {
        pt.x = x;
        pt.y = y;
        pt = this.localToGlobal(pt);

        return { x: pt.x, y: pt.y };
    }

    override function layerToLocal(x:Float, y:Float):Point {
        pt.x = x;
        pt.y = y;
        pt = this.globalToLocal(pt);

        return { x: pt.x, y: pt.y };
    }

    override function createCustomTile(x:Int, y:Int, width:Int, height:Int):DisplayTile {
        return tileset.addRect(new openfl.geom.Rectangle(x, y, width, height));
    }

    public function pendingBitmapData(path:String, bitmapData:openfl.display.BitmapData) {
        if (pending.exists(path)) {
            var bmpd = pending.get(path);
            if (bmpd != bitmapData) {
                bmpd.dispose();
            }
        }
        
        pending.set(path, bitmapData);
    }

    override function drawCustomTile(tile:CustomTile, rect:binpacking.Rect) {
        if (pending.exists(tile.path)) {
            var bmpd = pending.get(tile.path);
            
            drawBitmapData(tile, rect, bmpd);
        }
    }

    function drawBitmapData(tile:CustomTile, rect:binpacking.Rect, bmpd:BitmapData) {
        if (rect.width == bmpd.width && rect.height == bmpd.height) {
            tileset.bitmapData.copyPixels(bmpd, bmpd.rect, new openfl.geom.Point(rect.x, rect.y));
        } else {
            // Draw by scaling
            #if flash
            var matrix = new openfl.geom.Matrix();
            matrix.scale(rect.width / bmpd.width, rect.height / bmpd.height);
            matrix.translate(rect.x, rect.y);
            tileset.bitmapData.draw(bmpd, matrix);
            #else
            var image = lime.graphics.Image.fromBitmapData(bmpd);
            image.resize(Std.int(rect.width), Std.int(rect.height));
            var resizedBmpd = openfl.display.BitmapData.fromImage(image);
            tileset.bitmapData.copyPixels(resizedBmpd, resizedBmpd.rect, new openfl.geom.Point(rect.x, rect.y));
            resizedBmpd.dispose();
            #end
        }

        tile.x = Std.int(rect.x);
        tile.y = Std.int(rect.y);
        tile.width = Std.int(rect.width);
        tile.height = Std.int(rect.height);

        if (!tile.isDrawn) {
            tile.isDrawn = true;
            pending.remove(tile.path);

            tile.tile = createCustomTile(tile.x, tile.y, tile.width, tile.height);
            tile.id = addCustomTile(tile.tile);
        } else {
            tileset.updateRect(tile.tile, tile.x, tile.y, tile.width, tile.height);
        }

        bmpd.dispose();
    }

    override function redrawReservedSpace(map:Map<CustomTile, binpacking.Rect>) {
        // Take all bitmapDatas from texture
        var bitmapDatas:Map<CustomTile, BitmapData> = new Map();
        for (tile in map.keys()) {
            if (tile.isDrawn) {
                var bmpd = new BitmapData(tile.width, tile.height, true, 0x00000000);
                bmpd.copyPixels(tileset.bitmapData, new openfl.geom.Rectangle(tile.x, tile.y, tile.width, tile.height), new openfl.geom.Point(0, 0));
                bitmapDatas.set(tile, bmpd);
            } else if (pending.exists(tile.path)) {
                bitmapDatas.set(tile, pending.get(tile.path));
            }
        }

        // Clear area
        tileset.bitmapData.fillRect(new openfl.geom.Rectangle(reserved.x, reserved.y, reserved.width, reserved.height), 0x00000000);

        // Draw into new position
        for (tile in map.keys()) if (bitmapDatas.exists(tile)) {
            var rect = map.get(tile);
            var bmpd = bitmapDatas.get(tile);
            
            drawBitmapData(tile, rect, bmpd);
        }
    }

    override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {
            swfty.addAll(bmpd.width, bmpd.height);

            // Create tileset
            var rects = [];
            tiles = new IntMap();
            for (tile in swfty.tiles) {
                tiles.set(tile.id, rects.length);
                rects.push(new openfl.geom.Rectangle(tile.x, tile.y, tile.width, tile.height));
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

            // Only add on the display when we load a texture
            container.addChild(this);

            trace('Tilemap: ${swfty.name}, ${bmpd.width}, ${bmpd.height}');

            if (onComplete != null) onComplete();
        }

        #if sync
        complete(BitmapData.fromBytes(bytes));
        #else
        BitmapData.loadFromBytes(bytes).onComplete(complete).onError(onError);
        #end
    }

    override function dispose() {
        if (!disposed) {
            // TODO: !!!

            for (bmpd in pending) {
                bmpd.dispose();
            }
            pending = new StringMap();

            // Never too prudent, immediately dispose of all bitmap data associated with this layer
            /*if (texture != null) texture.dispose();
            for (tile in tiles) {
                tile.dispose();
            }
            tiles = new IntMap();*/
        }

        super.dispose();
    }
}