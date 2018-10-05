package swfty;

typedef Transform = {
    a: Float,
	b: Float,
	c: Float,
	d: Float,
	tx: Float,
	ty: Float,
}

@:structInit typedef ShapeDefinition = {
    > Transform,
    id: Int,
    bitmap: Int,
}

typedef SpriteDefinition = {
	> Transform,
    id: Int,
    shapes: Array<ShapeDefinition>,
	name: String,
    visible: Bool
}

typedef BitmapDefinition = {
	id: Int,
	x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef MovieClipDefinition = {
	id: Int,
    name: String,
	children: Array<SpriteDefinition>
}

typedef SWFTYJson = {
	definitions: Array<MovieClipDefinition>,
    tiles: Array<BitmapDefinition>
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