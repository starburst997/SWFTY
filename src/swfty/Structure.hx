package swfty;

enum abstract BlendMode(String) from String to String {
    var Normal      = 'normal';
    //var Layer       = 'layer';
    var Multiply    = 'multiply';
    var Screen      = 'screen';
    var Lighten     = 'lighten';
    var Darken      = 'darken';
    var Difference  = 'difference';
    var Add         = 'add';
    var Subtract    = 'subtract';
    var Invert      = 'invert';
    var Alpha       = 'alpha';
    var Erase       = 'erase';
    var Overlay     = 'overlay';
    var Hardlight   = 'hardlight';
}

enum abstract Align(String) to String {
    var Left;
    var Right;
    var Center;
    var Justify;
}

typedef Transform = {
    a: Float,
	b: Float,
	c: Float,
	d: Float,
	tx: Float,
	ty: Float,
}

typedef Rect = {
    x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef BitmapDefinition = {
	> Rect,
    id: Int
}

typedef Character = {
    id: Int,
    bitmap: Int,
    tx: Float,
    ty: Float
}

typedef FontDefinition = {
    id: Int,
    name: String,
    cleanName: String,
    color: Int,
    size: Float,
    bold: Bool,
    italic: Bool,
    bitmap: Int,
    ascent: Float,
    descent: Float,
    leading: Float,
    characters: Array<Character>
}

typedef ShapeDefinition = {
    > Transform,
    id: Int,
    bitmap: Int,
}

typedef TextDefinition = {
    font: Int,
    align: Align,
    size: Float,
    color: UInt,
    text: String,
    html: String,
    leftMargin: Float,
    rightMargin: Float,
    leading: Float,
    indent: Float,
    x: Float,
    y: Float,
    width: Float,
    height: Float
}

typedef ColorTransform = {
    r: Float,
    g: Float,
    b: Float,
    rAdd: Float,
    gAdd: Float,
    bAdd: Float
}

typedef SpriteDefinition = {
	> Transform,
    id: Int,
    shapes: Array<ShapeDefinition>,
    ?mask: Int,
    ?text: TextDefinition,
    ?blendMode: BlendMode,
    ?color: ColorTransform,
    alpha: Float,
	name: String,
    visible: Bool
}

typedef MovieClipDefinition = {
	id: Int,
    name: String,
	children: Array<SpriteDefinition>
}

typedef SWFTYJson = {
    tilemap: {
        width: Int,
        height: Int
    },
	definitions: Array<MovieClipDefinition>,
    tiles: Array<BitmapDefinition>,
    fonts: Array<FontDefinition>
}

typedef Rectangle = {
    width: Int,
    height: Int
}

typedef Config = {
    ?watch: Bool,
    ?pngquant: Bool,
    ?sharedFonts:Bool,
    ?files: Array<{
        name: String,
        ?pngquant: Bool,
        ?maxDimension: Rectangle,
        ?fontEnabled: Bool,
        ?maxFontDimension: Rectangle
    }>,
}