package swfty.renderer;

import haxe.ds.Option;

import swfty.renderer.Sprite.FinalSprite;

// TODO: Switch to class instead of Typedef?
typedef Line = {
    textWidth: Float,
    tiles: Array<{
        code: Int,
        x: Float,
        width: Float,
        tile: DisplayBitmap
    }>
}

class BaseText extends FinalSprite {

    public static inline var SPACE    = 0x20;
    public static inline var DOT      = 0x2E;
    public static inline var NEW_LINE = 0x0A;
    public static inline var RETURN   = 0x0D;

    public var text(default, set):String = null;

    public var textWidth(default, null):Float = 0.0;
    public var textHeight(default, null):Float = 0.0;
    public var multiline(default, null):Bool = false;
    public var originalText(default, null):String = '';

    var originalLines:Int = 0;

    // Add "..." at the end of the text if cannot fit within the boundaries
    public var short = false;

    // Scale the text down until it fits withing the boundaries
    // TODO: Use an Enum instead of bools
    public var fit = false;
    public var fitVertically = true;
    public var singleLine = false;

    public var color(default, set):Null<UInt> = null;
    public var align(get, set):Align;

    var _align:Option<Align> = None;
    var _width:Option<Float> = None;
    var _height:Option<Float> = None;

    var textDefinition:Null<TextType>;

    public function new(layer:BaseLayer, ?definition:TextType) {
        super(layer);

        loadText(definition);
    }

    // TODO: Meh, maybe rewrite those setter / getter, don't especially like it but not that much of a big deal anyway

    function set_align(align:Align) {
        _align = Some(align);
        return align;
    }

    function get_align():Align {
        return switch(_align) {
            case Some(a) : a;
            case None if (textDefinition != null) : textDefinition.align;
            case _ : Left;
        };
    }

    override function get_width():Float {
        return switch(_width) {
            case Some(w) : w;
            case None if (textDefinition != null) : textDefinition.width;
            case _ : 1;
        };
    }

    override function set_width(width:Float) {
        _width = Some(width);
        return width;
    }

    override function get_height():Float {
        return switch(_height) {
            case Some(h) : h;
            case None if (textDefinition != null) : textDefinition.height;
            case _ : 1;
        };
    }

    override function set_height(height:Float) {
        _height = Some(height);
        return height;
    }

    public function loadText(definition:TextType) {
        textDefinition = definition;

        if (definition != null) {
            multiline = definition.multiline;
            originalText = definition.text;
        }

        if (text == null && definition != null) {
            text = definition.text;
        } else if (this.text != null) {
            // Force refresh
            var text = this.text == originalText ? originalText = definition.text : this.text;
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

    function set_color(color:Null<UInt>) {
        if (color != this.color) {
            this.color = color;
            
            // Force refresh
            set_text('');
            set_text(text);
        }

        return color;
    }

    function set_text(text:String) {
        if (this.text == text) return text;

        this.text = text;

        // TODO: Somehow it seems like this doesn't work well in flash?
        var width = get_width();
        var height = get_height();

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

        var c = color == null ? textDefinition.color : color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        var size = textDefinition.size;
        var scale = size / textDefinition.font.size;

        y += (1 - (textDefinition.font.ascent / (textDefinition.font.ascent + textDefinition.font.descent))) * size; 
        
        var lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;

        var hasSpace = false;
        var lastSpaceX = 0.0;
        var currentLine:Line = {
            textWidth: 0.0,
            tiles: []
        };
        var lines:Array<Line> = [currentLine];

        // Get the '.' char
        var dot = textDefinition.font.get(DOT);

        for (i in 0...text.length) {
            var code = text.charCodeAt(i);

            if (code == SPACE) {
                lastSpaceX = x;
                hasSpace = true;
            }

            if (textDefinition.font.has(code)) {
                var char = textDefinition.font.get(code);
                var w = char.advance * scale;

                var tile = layer.createBitmap(char.bitmap.id, true);
                tile.color(r, g, b);
                tile.x = x + char.tx * scale;
                tile.y = y + char.ty * scale;

                tile.scaleX = tile.scaleY = scale;

                addBitmap(tile);

                currentLine.tiles.push({
                    code: code,
                    x: x,
                    width: w,
                    tile: tile
                });

                if (!multiline && fit) {
                    // TODO: For multiline check the "height" as well?
                    // TODO: Could probably be done simply at the end of each line?
                    if (code != SPACE && (x - textDefinition.x) + w > width) {
                        var scaleDown =  width / ((x - textDefinition.x) + w);

                        // Take all tiles and scale them down
                        for (line in lines) {
                            for (tile in line.tiles) {
                                tile.x *= scaleDown;
                                tile.width *= scaleDown;
                                tile.tile.scaleX *= scaleDown;
                                tile.tile.scaleY *= scaleDown;
                                tile.tile.x *= scaleDown;
                                tile.tile.y *= scaleDown;
                            }
                        }

                        x *= scaleDown;
                        y *= scaleDown;

                        size *= scaleDown;
                        scale = size / textDefinition.font.size;

                        if (!fitVertically) {
                            lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;
                        }
                        
                        w = char.advance * scale;
                    }

                } else if (short) {
                    // TODO: For multiline "short" text we should check the "height" and do it on the last line only!
                    if ((x - textDefinition.x) + w > (width - scale * dot.advance * 3) && (i <= text.length - 3)) {
                        // Set the remaining charaters as "..." and call it a day
                        for (j in 0...3) {
                            code = DOT;
                            char = textDefinition.font.get(code);
                            tile = layer.createBitmap(char.bitmap.id, true);
                            tile.color(r, g, b);
                            tile.x = x + char.tx * scale;
                            tile.y = y + char.ty * scale;

                            tile.scaleX = tile.scaleY = scale;

                            addBitmap(tile);

                            w = char.advance * scale;
                            currentLine.tiles.push({
                                code: code,
                                x: x,
                                width: w,
                                tile: tile
                            });

                            x += w;
                        }
                        break;
                    }
                } else if ((x - textDefinition.x) + w > width && hasSpace && multiline) {
                    y += lineHeight;
                    hasSpace = false;

                    // Take all characters until a space and move them to next line (ignoring the space)
                    var tiles = [];
                    var tile = currentLine.tiles.pop();
                    while(tile != null && tile.code == SPACE) { // Trim spaces
                        tile = currentLine.tiles.pop();
                    }

                    var offsetX = 0.0;
                    var maxWidth = (tile != null && tile.tile != null) ? (tile.x + tile.width) : 0.0; // TODO: Add the width of the tile also
                    while(tile != null && tile.code != SPACE) { // Remove any tiles until we reach a space
                        if (tile.tile != null) {
                            tile.tile.y += lineHeight;
                            offsetX = tile.x;
                        }
                        tiles.unshift(tile);

                        tile = currentLine.tiles.pop();
                        if (tile != null && tile.tile != null) {
                            maxWidth = tile.x + tile.width;
                        }
                    }

                    for (tile in tiles) {
                        tile.x -= offsetX - textDefinition.x;
                        tile.tile.x -= offsetX - textDefinition.x;
                    }

                    currentLine.textWidth = maxWidth - textDefinition.x;
                    if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;

                    currentLine = {
                        textWidth: 0.0,
                        tiles: tiles
                    };
                    lines.push(currentLine);

                    x -= offsetX - textDefinition.x;

                    if (singleLine) break;
                }

                x += w;
            } else {
                // Special cases
                switch(code) {
                    case NEW_LINE | RETURN : 
                        y += lineHeight;
                        x = textDefinition.x;
                        if (singleLine) break;
                    case _ : 
                }
            }
        }

        currentLine.textWidth = x - textDefinition.x;

        // We assume this is from the original text, might not be the bvest approach...
        if (originalLines == 0) originalLines = lines.length;

        // Center vertically
        if (fit && fitVertically) {
            for (line in lines)
                for (tile in line.tiles) 
                    tile.tile.y += (1 - size / textDefinition.size) * lineHeight / 2.0;
        }

        if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;
        textHeight = y + lineHeight;

        switch(align) {
            case Left    : 
            case Right   : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += width - line.textWidth;
            case Center  : 
                for (line in lines)
                    for (tile in line.tiles)
                        if (tile.tile != null) tile.tile.x += width / 2 - line.textWidth / 2;
            case Justify : trace('Justify not supported!!!');
        }

        return text;
    }
}