package swfty;

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

typedef BitmapDefinition = {
	id: Int,
	x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef Character = {
    > BitmapDefinition,
    tx: Float,
    ty: Float
}

typedef FontDefinition = {
    id: Int,
    name: String,
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

typedef SpriteDefinition = {
	> Transform,
    id: Int,
    shapes: Array<ShapeDefinition>,
    ?text: TextDefinition,
	name: String,
    visible: Bool
}

typedef MovieClipDefinition = {
	id: Int,
    name: String,
	children: Array<SpriteDefinition>
}

typedef SWFTYJson = {
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
    ?files: Array<{
        name: String,
        ?maxDimension: Rectangle,
        ?fontEnabled: Bool,
        ?maxFontDimension: Rectangle
    }>,
}