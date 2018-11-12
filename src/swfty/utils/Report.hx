package swfty.utils;

class Report {

    public static function isOrphaned(swfty:SWFTYJson, id:Int) {
        var movieClips = swfty.definitions;
        var fonts = swfty.fonts;

        function isOrphanedMC(id:Int) {
            for (mc in movieClips) {
                for (sprite in mc.children) {
                    if (sprite.id == id) {
                        return mc.name != '' && mc.name != null ? false : isOrphanedMC(mc.id);
                    }
                }
            }

            return true;
        }

        function isOrphanedBitmap(id:Int) {
            for (mc in movieClips) {
                for (sprite in mc.children) {
                    for (shape in sprite.shapes) {
                        if (shape.bitmap == id) {
                            return mc.name != '' && mc.name != null ? false : isOrphanedMC(mc.id);
                        }
                    }
                }
            }

            // Check if font
            for (font in fonts) {
                if (font.bitmap == id) {
                    return false;
                }

                for (char in font.characters) {
                    if (char.bitmap == id) {
                        return false;
                    }
                }
            }

            return true;
        }

        return isOrphanedBitmap(id);
    }

    public static function getPath(swfty:SWFTYJson, id:Int) {
        var movieClips = swfty.definitions;
        var fonts = swfty.fonts;
        
        function getPathMC(id:Int, path = '') {
            for (mc in movieClips) {
                for (sprite in mc.children) {
                    if (sprite.id == id) {
                        path = '(${mc.name}) ${sprite.name}.$path';
                        return getPathMC(mc.id, path);
                    }
                }
            }

            return path;
        }

        function getPathBitmap(id:Int, path = '') {
            for (mc in movieClips) {
                for (sprite in mc.children) {
                    for (shape in sprite.shapes) {
                        if (shape.bitmap == id) {
                            path = '(${mc.name}) ${sprite.name}.$path';
                            path = getPathMC(mc.id, path);
                            path = path.replace('() null', 'something');
                            path = path.replace('null', 'something');
                            return path.substr(0, path.length - 1);
                        }
                    }
                }
            }

            // Check if font
            for (font in fonts) {
                if (font.bitmap == id) {
                    return 'Font: ${getFont(font)}: ';
                }

                for (char in font.characters) {
                    if (char.bitmap == id) {
                        return 'Char ${char.id}: ${getFont(font)}: ';
                    }
                }
            }

            return path;
        }

        return getPathBitmap(id);
    }

    public static inline function getFont(font:FontDefinition) {
        return '${font.name}: ${font.size} (${font.characters.length})${font.bold ? ', bold' : ''}${font.italic ? ', italic' : ''}';
    }

    public static function getReport(swfty:SWFTYJson) {
        var report = '';

        inline function line(str = '') {
            report += '$str\n';
        }

        var bitmaps = swfty.tiles;
        var movieClips = swfty.definitions;
        var fonts = swfty.fonts;

        line();
        line('Tilemap: ${swfty.tilemap.width}x${swfty.tilemap.height}');

        line();
        line('Number of tiles: ${bitmaps.count()}');
        line('Number of movie clips: ${movieClips.count()}');
        line('Number of fonts: ${fonts.count()}');
        line();

        // Should be 0
        line('Orphaned: ${bitmaps.array().count(bitmap -> isOrphaned(swfty, bitmap.id))}');
        line();

        bitmaps.sort(function(a, b) a.width * a.height < b.width * b.height ? 1 : -1);

        line('Biggest tiles:');
        for (i in 0...Std.int(Math.min(20, bitmaps.length))) {
            var bitmap = bitmaps[i];
            line('  ${getPath(swfty, bitmap.id)}: ${bitmap.width}x${bitmap.height}');
        }

        line();

        line('Fonts:');
        fonts.sort(function(a, b) a.size < b.size ? 1 : -1);

        for (font in fonts) {
            line('  ${font.name}: ${font.size} (${font.characters.length})${font.bold ? ' , bold' : ''}${font.italic ? ' , italic' : ''}');
        }

        return report;
    }
}