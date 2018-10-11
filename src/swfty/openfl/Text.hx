package swfty.openfl;

import openfl.geom.ColorTransform;
import openfl.display.Tile;
import openfl.display.TileContainer;

typedef Line = {
    textWidth: Float,
    tiles: Array<{
        code: Int,
        tile: Tile
    }>
}

class Text extends TileContainer {

    public static inline var SPACE = 0x20;

    public var name:String = '';
    public var text(default, set):String = '';

    public var textWidth(default, null):Float = 0.0;
    public var textHeight(default, null):Float = 0.0;

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
        var x = definition.x;
        var y = definition.y;

        var c = definition.color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        var scale = definition.size / font.definition.size;
        var lineHeight = definition.size;

        var hasSpace = false;
        var lastSpaceX = 0.0;
        var currentLine:Line = {
            textWidth: 0.0,
            tiles: []
        };
        var lines:Array<Line> = [currentLine];

        for (i in 0...text.length) {
            var code = text.charCodeAt(i);

            if (code == SPACE) {
                lastSpaceX = x;
                hasSpace = true;
            }

            if (font.has(code)) {
                var char = font.get(code);
                var id = layer.getTile(char.bitmap);

                var rect = layer.tileset.getRect(id);
                if (rect != null) {
                    
                    var tile = new Tile(id);
                    tile.colorTransform = new ColorTransform(r/255, g/255, b/255, 1.0);
                    tile.x = x + char.tx;
                    tile.y = y + char.ty;

                    tile.scaleX = tile.scaleY = scale;

                    addTile(tile);

                    currentLine.tiles.push({
                        code: code,
                        tile: tile
                    });

                    var w = rect.width * scale;
                    
                    if ((x - definition.x) + w > definition.width && hasSpace) {
                        y += lineHeight;
                        hasSpace = false;

                        // Take all characters until a space and move them to next line (ignoring the space)
                        var tiles = [];
                        var tile = currentLine.tiles.pop();
                        var offsetX = 0.0;
                        var maxWidth = (tile != null && tile.tile != null) ? tile.tile.x : 0.0;
                        while(tile != null && tile.code != SPACE) {
                            if (tile.tile != null) {
                                tile.tile.y += lineHeight;
                                offsetX = tile.tile.x;
                            }
                            tiles.push(tile);

                            tile = currentLine.tiles.pop();
                            if (tile != null && tile.tile != null) maxWidth = tile.tile.x;
                        }

                        for (tile in tiles) tile.tile.x -= offsetX - definition.x;

                        currentLine.textWidth = maxWidth - definition.x;
                        if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;

                        currentLine = {
                            textWidth: 0.0,
                            tiles: tiles
                        };
                        lines.push(currentLine);

                        x -= offsetX - definition.x;
                    }

                    x += w;
                } else {
                    currentLine.tiles.push({
                        code: code,
                        tile: null
                    });
                }
            }
        }

        currentLine.textWidth = x - definition.x;

        if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;
        textHeight = y + lineHeight;

        switch(definition.align) {
            case Left    : 
            case Right   : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += definition.width - line.textWidth;
            case Center  : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += definition.width / 2 - line.textWidth / 2;
            case Justify : trace('Justify not supported!!!');
        }

        return text;
    }
}