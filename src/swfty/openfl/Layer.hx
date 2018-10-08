package swfty.openfl;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

import openfl.geom.Rectangle;
import openfl.display.Tileset;
import openfl.display.BitmapData;
import openfl.display.Tilemap;
import openfl.events.Event;

class Layer extends Tilemap {

    var afterFrames:Array<Void->Void> = [];

    var tiles:IntMap<Int>;
    var ids:IntMap<MovieClipDefinition>;
    var fonts:IntMap<Font>;
    var mcs:StringMap<MovieClipDefinition>;

    public static inline function create(width:Int, height:Int, ?tileset) {
        return new Layer(width, height, tileset);
    }

    public static inline function createAsync(width:Int, height:Int, bytes:Bytes, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadTileset(bytes, (tileset, json, characters) -> {
            var layer = create(width, height, tileset);
            layer.loadJson(json, characters);
            onComplete(layer);
        }, onError);
    }

    public function new(width:Int, height:Int, ?tileset) {
        super(width, height, tileset);

        tiles = new IntMap();
        ids = new IntMap();
        fonts = new IntMap();
        mcs = new StringMap();

        /*addEventListener(Event.ENTER_FRAME, render);

        #if html5
        // Weird OpenFL html5 bug with tilemap...
        afterFrame(() -> {
            x += 0.00000001;
            afterFrame(() -> {
                x -= 0.00000001;
            });
        });
        #end*/
    }

    public function dispose() {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    inline function afterFrame(f:Void->Void) {
        afterFrames.push(f);
    }

    function render(e) {
        if (afterFrames.length > 0) {
            var copy = [for (f in afterFrames) f];
            afterFrames = [];

            for (f in copy) f();
        }
    }

    public inline function getTile(id:Int):Int {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            -1;
        } 
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
        return [for (key in mcs.keys()) key];
    }

    public function resize(width:Int, height:Int) {

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
        loadTileset(bytes, (tileset, json, characters) -> {
            this.tileset = tileset;
            loadJson(json, characters);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson, characters:IntMap<IntMap<Int>>) {
        for (i in 0...json.tiles.length) {
            var tile = json.tiles[i];
            tiles.set(tile.id, i);
        }

        for (definition in json.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
            ids.set(definition.id, definition);
        }

        for (font in json.fonts) if (characters.exists(font.id)) {
            var obj = Font.create(this, font, characters.get(font.id));
            fonts.set(font.id, obj);
        }
    }

    public static function loadTileset(bytes:Bytes, onComplete:Tileset->SWFTYJson->IntMap<IntMap<Int>>->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                // Create tileset
                var i = 0;
                var rects = [];
                var map = new IntMap();
                for (tile in json.tiles) {
                    map.set(tile.id, i++);
                    rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
                }

                // Fonts
                var fontsCharacters = new IntMap();
                for (font in json.fonts) if (map.exists(font.bitmap)) {
                    var id = map.get(font.bitmap);
                    var tile = rects[id];
                    
                    var characters = new IntMap();
                    for (character in font.characters) {
                        characters.set(character.id, i++);
                        rects.push(new Rectangle(character.x + tile.x, character.y + tile.y, character.width, character.height));
                    }

                    fontsCharacters.set(font.id, characters);
                }

                var tileset = new Tileset(bmpd, rects);

                trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

                onComplete(tileset, json, fontsCharacters);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        #if sync
        complete(BitmapData.fromBytes(tilemapBytes));
        #else
        BitmapData.loadFromBytes(tilemapBytes).onComplete(complete).onError(e -> onError(e));
        #end
    } 
}