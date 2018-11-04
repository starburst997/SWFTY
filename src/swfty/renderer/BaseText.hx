package swfty.renderer;

import swfty.renderer.Sprite.FinalSprite;

typedef Line = {
    textWidth: Float,
    tiles: Array<{
        code: Int,
        tile: DisplayBitmap
    }>
}

class BaseText extends FinalSprite {

    public static inline var SPACE = 0x20;

    public var text(default, set):String = null;

    public var textWidth(default, null):Float = 0.0;
    public var textHeight(default, null):Float = 0.0;

    var textDefinition:Null<TextType>;

    public function new(layer:EngineLayer, ?definition:TextType) {
        super(layer);

        loadText(definition);
    }

    public function loadText(definition:TextType) {
        textDefinition = definition;
        if (text == null && definition != null) {
            text = definition.text;
        } else if (this.text != null) {
            // Force refresh
            var text = this.text;
            set_text('');
            set_text(text);
        }

        return this;
    }

    public override function reload() {
        super.reload();
        
        if (textDefinition != null && textDefinition.font != null && layer.hasFont(textDefinition.font.id)) {
            textDefinition.font = layer.getFont(textDefinition.font.id);
            loadText(textDefinition);
        }
    } 

    function set_text(text:String) {
        if (this.text == text) return text;

        this.text = text;

        // Clear tiles
        removeAll();

        if (text.empty()) {
            textWidth = 0;
            textHeight = 0;
            return text;
        }

        if (textDefinition == null || textDefinition.font == null) return text;

        // Show characters
        var x = textDefinition.x;
        var y = textDefinition.y;

        var c = textDefinition.color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        var scale = textDefinition.size / textDefinition.font.size;
        var lineHeight = textDefinition.size;

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

            if (textDefinition.font.has(code)) {
                var char = textDefinition.font.get(code);
                var tile = layer.createBitmap(char.bitmap.id, true);
                tile.color(r, g, b);
                tile.x = x + char.tx;
                tile.y = y + char.ty;

                tile.scaleX = tile.scaleY = scale;

                addBitmap(tile);

                currentLine.tiles.push({
                    code: code,
                    tile: tile
                });

                var w = char.bitmap.width * scale;
                
                if ((x - textDefinition.x) + w > textDefinition.width && hasSpace) {
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

                    for (tile in tiles) tile.tile.x -= offsetX - textDefinition.x;

                    currentLine.textWidth = maxWidth - textDefinition.x;
                    if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;

                    currentLine = {
                        textWidth: 0.0,
                        tiles: tiles
                    };
                    lines.push(currentLine);

                    x -= offsetX - textDefinition.x;
                }

                x += w;
            }
        }

        currentLine.textWidth = x - textDefinition.x;

        if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;
        textHeight = y + lineHeight;

        switch(textDefinition.align) {
            case Left    : 
            case Right   : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += textDefinition.width - line.textWidth;
            case Center  : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += textDefinition.width / 2 - line.textWidth / 2;
            case Justify : trace('Justify not supported!!!');
        }

        return text;
    }
}