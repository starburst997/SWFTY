package swfty.openfl;

import openfl.geom.ColorTransform;
import openfl.display.Tile;
import openfl.display.TileContainer;

class Text extends TileContainer {

    public var name:String;
    public var text(default, set):String;

    var layer:Layer;
    var font:Font;
    var definition:TextDefinition;

    public static inline function create(layer:Layer, definition:TextDefinition) {
        return new Text(layer, definition);
    }

    public function new(layer:Layer, definition:TextDefinition) {
        super();

        this.layer = layer;
        this.definition = definition;

        font = layer.getFont(definition.font);
        text = definition.text;
    }

    function set_text(text:String) {
        if (font == null || this.text == text) return text;

        // Clear tiles
        while(numTiles > 0) removeTileAt(0);

        // Show characters
        var x = 0.0;
        var y = 0.0;

        var c = definition.color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        for (i in 0...text.length) {
            var code = text.charCodeAt(i);

            if (font.has(code)) {
                var id = font.get(code);

                var tile = new Tile(id);
                tile.colorTransform = new ColorTransform(r/255, g/255, b/255, 1.0);
                tile.x = x;
                tile.y = y;

                addTile(tile);

                /*if (tile.rect != null) {
                    x += tile.rect.width;
                    y += 0;
                }*/
            }

            x += 30;
            y += 0;
        }

        return text;
    }
}