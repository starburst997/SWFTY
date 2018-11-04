package heaps.swfty.renderer;

import heaps.swfty.renderer.Sprite;

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

    public static inline function create() {
        return new Layer();
    }

    public function new() {
        super(null);

        sprites = [];

        mcs = new StringMap();
        tiles = new IntMap();
        swfty = None;
    }

    public function getColor() {
        return curColor;
    } 

    public function addSprite(sprite:Sprite) {
        sprites.push(sprite);
    }

    public function removeSprite(sprite:Sprite) {
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
        return [for (key in mcs.keys()) key];
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
        return if (!hasMC(linkage)) {
            switch(swfty) {
                case Some(swfty) : Log.warn('Linkage: $linkage does not exists!');
                case None : 
            }
            Sprite.create(this, linkage);
        } else {
            var sprite = Sprite.create(this, mcs.get(linkage));
            sprite;
        }
    }

    public inline function getMC(linkage:String):MovieClipType {
        return mcs.get(linkage);
    }

    public inline function hasMC(linkage:String) {
        return mcs.exists(linkage);
    }

    public function reload() {
        for (sprite in sprites) sprite.reload();
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tile, swfty) -> {
            this.tile = tile;
            loadSWFTY(swfty);
            onComplete();
        }, onError);
    }

    public function loadSWFTY(swfty:SWFTYType) {
        mcs = new StringMap();
        tiles = new IntMap();
        
        for (definition in swfty.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
        }

        for (tile in swfty.tiles) {
            tiles.set(tile.id, this.tile.sub(tile.x, tile.y, tile.width, tile.height));
        }

        this.swfty = Some(swfty);

        reload();
    }

    public static function loadBytes(bytes:Bytes, onComplete:h2d.Tile->SWFTYType->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        if (!entries.exists('tilemap.png') || (!entries.exists('definitions.json') && !entries.exists('definitions.bin'))) {
            onError('Missing file');
            return;
        }

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));

        function complete(tile:h2d.Tile) {
            var swfty = if (entries.exists('definitions.json')) {
                var jsonString = Zip.getString(entries.get('definitions.json'));
                var json:SWFTYJson = try {
                    haxe.Json.parse(jsonString);
                } catch(e:Dynamic) {
                    null;
                }
                json == null ? null : SWFTYType.fromJson(json);
            } else {
                var bytes = Zip.getBytes(entries.get('definitions.bin'));
                hxbit.Serializer.load(bytes, SWFTYType);
            }

            trace('Tilemap: ${tile.width}, ${tile.height}');

            onComplete(tile, swfty);
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