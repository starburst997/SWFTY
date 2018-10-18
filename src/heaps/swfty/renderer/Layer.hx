package heaps.swfty.renderer;

import swfty.renderer.Font;

import h2d.Tile;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

class Layer extends h2d.TileGroup {
    
    public var json:SWFTYJson;

    var tiles:IntMap<h2d.Tile>;
    var ids:IntMap<MovieClipDefinition>;
    var fonts:IntMap<Font>;
    var mcs:StringMap<MovieClipDefinition>;

    var sprites:Array<Sprite>;

    var names:Array<String>;

    public static inline function create(?tile:h2d.Tile, ?parent) {
        return new Layer(tile, parent);
    }

    public function new(?tile:h2d.Tile, ?parent) {
        super(tile, parent);

        sprites = [];

        tiles = new IntMap();
        ids = new IntMap();
        fonts = new IntMap();
        mcs = new StringMap();
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

    public inline function drawTile(x : Int, y : Int, sx : Float, sy : Float, r : Float, c : h3d.Vector, t : Tile) {
		content.addTransform(x, y, sx, sy, r, c, t);
	}

    public function update(dt:Float) {
        clear();
        for (sprite in sprites) sprite.update(dt);
    }

    public inline function getFont(id:Int) {
        return fonts.get(id);
    }

    public inline function hasFont(id:Int) {
        return fonts.exists(id);
    }

    public inline function getDefinition(id:Int):MovieClipDefinition {
        return ids.get(id);
    }

    public inline function hasDefinition(id:Int):Bool {
        return ids.exists(id);
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
        loadBytes(bytes, (tile, json) -> {
            this.tile = tile;
            loadJson(json);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson) {
        this.json = json;

        for (i in 0...json.tiles.length) {
            var tile = json.tiles[i];
            tiles.set(tile.id, this.tile.sub(tile.x, tile.y, tile.width, tile.height));
        }

        for (definition in json.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
            ids.set(definition.id, definition);
        }

        for (font in json.fonts) {
            var obj = Font.create(this, font);
            fonts.set(font.id, obj);
        }
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

        function complete(tile:h2d.Tile) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                trace('Tilemap: ${tile.width}, ${tile.height}');

                onComplete(tile, json);
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