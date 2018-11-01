package heaps.swfty.renderer;

import h2d.RenderContext;
import h2d.Tile;

import haxe.ds.Option;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

class Layer extends h2d.TileGroup {
    
    public var swfty:Option<SWFTYType>;

    var tiles:IntMap<h2d.Tile>;
    var mcs:StringMap<MovieClipType>;
    
    var sprites:Array<Sprite>;
    var names:Array<String>;

    public static inline function create(?tile:h2d.Tile, ?parent) {
        return new Layer(tile, parent);
    }

    public function new(?tile:h2d.Tile, ?parent) {
        super(tile, parent);

        sprites = [];

        mcs = new StringMap();
        tiles = new IntMap();
    }

    public function getColor() {
        return curColor;
    } 

    public function addTile(sprite:Sprite) {
        sprites.push(sprite);
    }

    public function removeTile(sprite:Sprite) {
        sprites.remove(sprite);
    }

    public inline function drawTile(x:Int, y:Int, sx:Float, sy:Float, r:Float, c:h3d.Vector, t:Tile) {
		content.addTransform(x, y, sx, sy, r, c, t);
	}

    override function draw(ctx:RenderContext) {
        clear();
        for (sprite in sprites) sprite.render(ctx);
        
        super.draw(ctx);
    }

    public function update(dt:Float) {
        for (sprite in sprites) sprite.update(dt);
    }

    public inline function getFont(id:Int):FontType {
        return switch(swfty) {
            case Some(swfty) : swfty.fonts.get(id);
            case None : null;
        }
    }

    public inline function hasFont(id:Int) {
        return switch(swfty) {
            case Some(swfty) : swfty.fonts.exists(id);
            case None : false;
        }
    }

    public inline function getDefinition(id:Int):MovieClipType {
        return switch(swfty) {
            case Some(swfty) : swfty.definitions.get(id);
            case None : null;
        }
    }

    public inline function hasDefinition(id:Int):Bool {
        return switch(swfty) {
            case Some(swfty) : swfty.definitions.exists(id);
            case None : false;
        }
    }

    public inline function getAllNames() {
        if (names == null) names = [for (key in mcs.keys()) key];
        return names;
    }

    public inline function getTile(id:Int):h2d.Tile {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            tile.sub(0, 0, 1, 1);
        } 
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
        loadBytes(bytes, (tile, swfty) -> {
            this.tile = tile;
            loadSWFTY(swfty);
            onComplete();
        }, onError);
    }

    public function loadSWFTY(swfty:SWFTYType) {
        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }

        for (tile in swfty.tiles) {
            tiles.set(tile.id, this.tile.sub(tile.x, tile.y, tile.width, tile.height));
        }

        this.swfty = Some(swfty);
    }

    public static function createAsync(bytes:Bytes, ?parent, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tile, swfty) -> {
            var layer = create(tile, parent);
            layer.loadSWFTY(swfty);
            onComplete(layer);
        }, onError);
    }

    public static function loadBytes(bytes:Bytes, onComplete:h2d.Tile->SWFTYType->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(tile:h2d.Tile) {
            #if release
            try {
            #end
                var swfty = if (entries.exists('definitions.json')) {
                    var jsonString = Zip.getString(entries.get('definitions.json'));
                    var json:SWFTYJson = haxe.Json.parse(jsonString);
                    SWFTYType.fromJson(json);
                } else {
                    var bytes = Zip.getBytes(entries.get('definitions.bin'));
                    hxbit.Serializer.load(bytes, SWFTYType);
                }

                trace('Tilemap: ${tile.width}, ${tile.height}');

                onComplete(tile, swfty);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        #if js
        Image.loadBytes('tilemap.png', tilemapBytes, function(image) {
            complete(image.toTile());
        });
        #else
        complete(Image.create(tilemapBytes).toTile());
        #end
    }
}