package swfty.renderer;

import haxe.Utf8;

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

    public var _color(default, set):Null<UInt> = null;
    public var align(get, set):Align;

    public var scaleFont = 1.0;

    var _align:Option<Align> = None;
    var __width:Option<Float> = None;
    var __height:Option<Float> = None;

    var textDefinition:Null<TextType>;

    public function new(layer:BaseLayer, ?definition:TextType) {
        super(layer);

        _isText = true;

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

    override function get__width():Float {
        return switch(__width) {
            case Some(w) : w;
            case None if (textDefinition != null) : textDefinition.width * scaleFont;
            case _ : 1;
        };
    }

    override function set__width(width:Float) {
        __width = Some(width);
        return width;
    }

    override function get__height():Float {
        return switch(__height) {
            case Some(h) : h;
            case None if (textDefinition != null) : textDefinition.height * scaleFont;
            case _ : 1;
        };
    }

    override function set__height(height:Float) {
        __height = Some(height);
        return height;
    }

    public function loadText(definition:TextType) {
        textDefinition = definition;

        if (definition != null) {
            multiline = definition.multiline;
            originalText = definition.text;

            forceBounds = {
                x: 0,
                y: 0,
                width: definition.width,
                height: definition.height
            };
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
        
        if (textDefinition != null && textDefinition.font != null && _layer.hasFont(textDefinition.font.id)) {
            textDefinition.font = _layer.getFont(textDefinition.font.id);
            loadText(textDefinition);
        }
    }

    function set__color(color:Null<UInt>) {
        if (color != this._color) {
            this._color = color;
            
            // Force refresh
            set_text('');
            set_text(text);
        }

        return color;
    }

    inline function getLineHeight() {
        if (textDefinition == null || textDefinition.font == null) return 0.0;

        var size = textDefinition.size * scaleFont;
        return (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;
    }

    public inline function checkMultiline() {
        return  multiline && (_height > getLineHeight() * 1.70);
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
        
        // TODO: If we want to use the TextField bounds instead of characters
        //addEmptyRect(0, 0, textDefinition.width * scaleX, textDefinition.height * scaleY);

        // Show characters
        var x = 0.0;
        var y = 0.0;

        var c = _color == null ? textDefinition.color : _color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        var size = textDefinition.size * scaleFont;
        var scale = size / textDefinition.font.size;
        var _scale = layer.getInternalScale();

        if (textDefinition.font.ascent + textDefinition.font.descent != 0.0) {
            y += (1 - (textDefinition.font.ascent / (textDefinition.font.ascent + textDefinition.font.descent))) * size; 
        }
        
        var lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;

        // TODO: Something's wrong here, there must be a value i'm missing somewhere...
        if (lineHeight == 0.0) lineHeight = size;
        
        // Check if it's really multiline
        var multiline = checkMultiline();

        var hasSpace = false;
        var lastSpaceX = 0.0;
        var currentLine:Line = {
            textWidth: 0.0,
            tiles: []
        };
        var lines:Array<Line> = [currentLine];

        // Get the '.' char
        var dot = textDefinition.font.get(DOT);

        var skip = false;
        var i = -1;
        Utf8.iter(text, function(code){
            if (skip) return;
            i++;

            if (code == SPACE) {
                lastSpaceX = x;
                hasSpace = true;
            }

            if (textDefinition.font.has(code)) {
                var char = textDefinition.font.get(code);
                var w = char.advance * scale;

                var tile = _layer.createBitmap(char.bitmap.id, this, true);
                tile.color(r, g, b);
                tile.x = x + char.tx * scale;
                tile.y = y + char.ty * scale;

                tile.scaleX = scale / (char.bitmap.originalWidth > 0 && char.bitmap.width > 0 ? char.bitmap.width / char.bitmap.originalWidth : _scale);
                tile.scaleY = scale / (char.bitmap.originalHeight > 0 && char.bitmap.height > 0 ? char.bitmap.height / char.bitmap.originalHeight : _scale);

                addBitmap(tile);

                currentLine.tiles.push({
                    code: code,
                    x: x,
                    width: w,
                    tile: tile
                });

                if (short) {
                    // TODO: For multiline "short" text we should check the "height" and do it on the last line only!
                    if (x + w > (_width - scale * dot.advance * 3) && (i <= text.length - 3)) {
                        // Set the remaining charaters as "..." and call it a day
                        for (j in 0...3) {
                            code = DOT;
                            char = textDefinition.font.get(code);
                            tile = _layer.createBitmap(char.bitmap.id, this, true);
                            tile.color(r, g, b);
                            tile.x = x + char.tx * scale;
                            tile.y = y + char.ty * scale;

                            tile.scaleX = scale / (char.bitmap.originalWidth > 0 && char.bitmap.width > 0 ? char.bitmap.width / char.bitmap.originalWidth : _scale);
                            tile.scaleY = scale / (char.bitmap.originalHeight > 0 && char.bitmap.height > 0 ? char.bitmap.height / char.bitmap.originalHeight : _scale);

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

                        skip = true;
                        return;
                    }
                } else if (x + w > _width && hasSpace && multiline) {
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
                        tile.x -= offsetX;
                        tile.tile.x -= offsetX;
                    }

                    currentLine.textWidth = maxWidth;
                    if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;

                    currentLine = {
                        textWidth: 0.0,
                        tiles: tiles
                    };
                    lines.push(currentLine);

                    x -= offsetX;

                    if (singleLine) {
                        skip = true;
                        return;
                    };
                }

                x += w;
            } else {
                // Special cases
                switch(code) {
                    case NEW_LINE | RETURN : 
                        currentLine.textWidth = x;
                        
                        y += lineHeight;
                        x = 0.0;
                        
                        if (singleLine) {
                            skip = true;
                            return;
                        };

                        currentLine = {
                            textWidth: 0.0,
                            tiles: []
                        };
                        lines.push(currentLine);
                    case _ : 
                }
            }
        });

        currentLine.textWidth = x;

        // We assume this is from the original text, might not be the bvest approach...
        if (originalLines == 0) originalLines = lines.length;

        // Makes sure everything fits within the bounding box
        if (!multiline && (fit || short)) {
            if (currentLine.textWidth > _width) {
                var scaleDown =  _width / currentLine.textWidth;

                // Take all tiles and scale them down
                for (line in lines) {
                    for (tile in line.tiles) {
                        // I agree not the most elegant way to do it, but works great and is cheap
                        // TODO: We could wrap around all glyphs into another Sprite and set the scale on it...
                        tile.x *= scaleDown;

                        tile.width *= scaleDown;
                        tile.tile.scaleX *= scaleDown;
                        tile.tile.scaleY *= scaleDown;

                        // TODO: Is this necessary??
                        tile.tile.x *= scaleDown;
                        tile.tile.y *= scaleDown;
                    }
                }

                currentLine.textWidth *= scaleDown;

                size *= scaleDown;
                scale = size / textDefinition.font.size;

                if (!fitVertically) {
                    lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;
                }
            }
        }

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
                // TODO: We still have an issue here, investigate
                //trace('--- RIGHT', _name, text, _width);
                for (line in lines) {
                    //trace('LINE', _width - line.textWidth);
                    for (tile in line.tiles)
                        if (tile.tile != null) tile.tile.x += _width - line.textWidth;
                }
            case Center  : 
                for (line in lines)
                    for (tile in line.tiles)
                        if (tile.tile != null) tile.tile.x += _width / 2 - line.textWidth / 2;
            case Justify : 
                trace('Justify not supported!!!');
        }

        return text;
    }
}