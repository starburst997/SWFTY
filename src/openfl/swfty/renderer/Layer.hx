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
    static var rect = new openfl.geom.Rectangle();
    static var matrix = new openfl.geom.Matrix();

    var renderId:Int = 0;
    var pending:StringMap<BitmapData> = new StringMap();

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }

    public function new(?width:Int, ?height:Int) {
        // TODO: If null, it should maybe be the stage's dimensions??? Or at least on the "getter"
        super(width == null ? 256 : width, height == null ? 256 : height);

        tileAlphaEnabled = true;
		tileBlendModeEnabled = false;
		tileColorTransformEnabled = true;

        _width = width;
        _height = height;
    }

    override function update(dt:Float) {
        super.update(dt);
    }

    /*override function __renderGL(renderer:openfl.display.OpenGLRenderer):Void
	{
        // TODO: Create my own implementation creating the buffer on the swfty loop directly
        //       This is a copy / paste of GLTilemap from 8.4.0 because Context3D stuff is MEGA SLOW
        openfl.opengl.GLTilemap.render(this, renderer);
		__renderEvent(renderer);
	}*/

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

    override function disposeTempBitmap(temp:EngineBitmap) {
        super.disposeTempBitmap(temp);
        
        // Makes sure we remove it from parent
        if (temp.parent != null) {
            temp.parent.removeTile(temp);   
        }
    }

    override function createCustomTile(x:Float, y:Float, width:Float, height:Float):DisplayTile {
        return if (tempTiles.length > 0) {
            var tile = tempTiles.pop();
            updateDisplayTile(tile, x, y, width, height);
            tile;
        } else {
            rect.setTo(x, y, width, height);
            tileset.addRect(rect);
        }
    }

    public function getData(id:DisplayTile) {
        @:privateAccess var tiles = tileset.__data;
        return if (id < tiles.length && id >= 0) {
            tiles[id];
        } else {
            null;
        }
    }

    override function updateDisplayTile(id:DisplayTile, x:Float, y:Float, width:Float, height:Float) {
        var data = getData(id);
        if (data != null) {
            data.x = Std.int(x);
            data.y = Std.int(y);
            data.width = Std.int(width);
            data.height = Std.int(height);

            if (tileset.bitmapData != null && data.width > 0 && data.height > 0 && tileset.bitmapData.width > 0 && tileset.bitmapData.height > 0) {
                #if flash
                @:privateAccess data.__update(tileset.bitmapData);
                #end

                // Fix UV using floats
                @:privateAccess data.__uvX = x / tileset.bitmapData.width;
                @:privateAccess data.__uvY = y / tileset.bitmapData.height;
                @:privateAccess data.__uvWidth = (x + width) / tileset.bitmapData.width;
                @:privateAccess data.__uvHeight = (y + height) / tileset.bitmapData.height;
            }
        }
    }

    public function pendingBitmapData(path:String, bitmapData:openfl.display.BitmapData) {
        if (pending.exists(path)) {
            var bmpd = pending.get(path);
            if (bmpd != bitmapData) {
                #if !no_dispose_bmpd
                bmpd.dispose();
                #end
            }
        }
        
        pending.set(path, bitmapData);
    }

    override function drawCustomTile(tile:CustomTile, rect:binpacking.Rect) {
        if (pending.exists(tile.path)) {
            var bmpd = pending.get(tile.path);
            drawBitmapData(tile, rect, bmpd, true);
        }
    }

    function drawBitmapData(tile:CustomTile, rect:binpacking.Rect, bmpd:BitmapData, canDispose:Bool) {
        if (disposed) {
            #if !no_dispose_bmpd
            if (canDispose) bmpd.dispose();
            #end
            return;
        }
        
        var padding = 1;
        if ((rect.width - padding*2) == bmpd.width && (rect.height - padding*2) == bmpd.height) {
            /*pt.setTo(rect.x + padding, rect.y + padding);
            tileset.bitmapData.copyPixels(bmpd, bmpd.rect, pt);*/

            matrix.identity();
            matrix.translate(rect.x + padding, rect.y + padding);
            tileset.bitmapData.draw(bmpd, matrix, null, null, null, false);
        } else {
            // Draw by scaling
            #if flash
            matrix.identity();
            matrix.scale((rect.width - padding*2) / bmpd.width, (rect.height - padding*2) / bmpd.height);
            matrix.translate(rect.x + padding, rect.y + padding);
            tileset.bitmapData.draw(bmpd, matrix, null, null, null, true);
            #else

            // TODO: CopyPixels is buggy in this version of Lime, use plain old draw... Shouldn't be too costly
            matrix.identity();
            matrix.scale((rect.width - padding*2) / bmpd.width, (rect.height - padding*2) / bmpd.height);
            matrix.translate(rect.x + padding, rect.y + padding);
            tileset.bitmapData.draw(bmpd, matrix, null, null, null, true);

            /*var width = Std.int(rect.width) - padding*2;
            var height = Std.int(rect.height) - padding*2;
            if (width < 1) width = 1;
            if (height < 1) height = 1;

            trace('Need resizing! $width, $height');

            var image = lime.graphics.Image.fromBitmapData(bmpd);//.clone(); // TODO: .clone() is needed otherwise we crash?
            image.resize(width, height);
            var resizedBmpd = openfl.display.BitmapData.fromImage(image);
            tileset.bitmapData.copyPixels(resizedBmpd, resizedBmpd.rect, new openfl.geom.Point(rect.x + padding, rect.y + padding));
            resizedBmpd.dispose();*/
            #end
        }

        tile.x = Std.int(rect.x) + padding;
        tile.y = Std.int(rect.y) + padding;
        tile.width = Std.int(rect.width) - padding*2;
        tile.height = Std.int(rect.height) - padding*2;

        pending.remove(tile.path);
        
        if (!tile.isDrawn) {
            tile.isDrawn = true;

            tile.tile = createCustomTile(tile.x, tile.y, tile.width, tile.height);
            tile.id = addCustomTile(tile.tile);
        } else {
            updateDisplayTile(tile.tile, tile.x, tile.y, tile.width, tile.height);
        }

        #if !no_dispose_bmpd
        if (canDispose) bmpd.dispose();
        #end
    }

    override function redrawReservedSpace(map:Map<CustomTile, binpacking.Rect>) {
        // Take all bitmapDatas from texture
        var bitmapDatas:Map<CustomTile, BitmapData> = new Map();
        for (tile in map.keys()) {
            if (tile.isDrawn) {
                var bmpd = new BitmapData(tile.width, tile.height, true, 0x00000000);
                rect.setTo(tile.x, tile.y, tile.width, tile.height);
                pt.setTo(0, 0);
                bmpd.copyPixels(tileset.bitmapData, rect, pt);
                bitmapDatas.set(tile, bmpd);
            } else if (pending.exists(tile.path)) {
                bitmapDatas.set(tile, pending.get(tile.path));
            }
        }

        // Clear area
        // #if mobile
        // // Fucking openfl, absolutely everything is a gamble if it will work or not
        // for (x in Std.int(reserved.x)...Std.int(reserved.x + reserved.width)) {
        //     for (y in Std.int(reserved.y)...Std.int(reserved.y + reserved.height)) {
        //         tileset.bitmapData.setPixel32(x, y, 0x00000000);
        //     }
        // }
        // #else
        rect.setTo(reserved.x, reserved.y, reserved.width, reserved.height);
        tileset.bitmapData.fillRect(rect, 0x00000000);
        //#end

        // Draw into new position
        for (tile in map.keys()) if (bitmapDatas.exists(tile)) {
            var rect = map.get(tile);
            var bmpd = bitmapDatas.get(tile);
            
            drawBitmapData(tile, rect, bmpd, true);
        }
    }

    override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {

            if (bmpd == null) {
                if (onError != null) onError('Null bitmapData');
                return;
            }

            swfty.addAll(bmpd.width, bmpd.height);

            // Create tileset
            var tileset = new Tileset(bmpd);
            tiles = new IntMap();
            
            var i = 0;
            for (tile in swfty.tiles) {
                tiles.set(tile.id, i++);
                
                rect.setTo(tile.x, tile.y, tile.width, tile.height);
                tileset.addRect(rect);
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

            this.tileset = tileset;

            // Only add on the display when we load a texture
            container.addChild(this);

            trace('Tilemap: ${swfty.name}, ${bmpd.width}, ${bmpd.height}');

            if (onComplete != null) onComplete();
        }

        #if sync
        complete(BitmapData.fromBytes(bytes));
        #else
        BitmapData.loadFromBytes(bytes).onComplete(complete).onError(function(e) if (onError != null) onError(e));
        #end
    }

    override function dispose(force = false) {
        if (!disposed) {
            if (!updating || force) {
                #if !no_dispose_bmpd
                for (bmpd in pending) {
                    bmpd.dispose();
                }
                #end
                pending = new StringMap();

                if (tileset != null && tileset.bitmapData != null) {
                    #if !no_dispose_bmpd
                    tileset.bitmapData.dispose();
                    #end
                    tileset.bitmapData = null;
                }
            }
        }

        super.dispose(force);
    }
}