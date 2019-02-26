package openfl.swfty.renderer;

typedef EngineSprite = openfl.display.TileContainer;
typedef EngineBitmap = openfl.display.Tile;

@:keepSub // Fix DCE=full
class FinalSprite extends BaseSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        this.tileset = layer.tileset;

        super(layer, definition, linkage);
    }

    override function set__name(name:String) {
        if (_parent != null) {
            @:privateAccess _parent._names.set(name, this);
        }
        
        return super.set__name(name);
    }

    override function refresh() {
        tileset = layer.tileset;
    }

    public override function calcBounds(?relative:BaseSprite):Rectangle {
        var rect = this.getBounds(relative == null ? this : relative);
        return {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        }
    }

    override function hasParent():Bool {
        return this.parent != null;
    }

    public override function top() {
        if (this.parent != null) parent.setTileIndex(this, parent.numTiles - 1);
    }

    public override function bottom() {
        if (this.parent != null) parent.setTileIndex(this, 0);
    }

    public override function addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        sprite._parent = this;
        super.addSpriteAt(sprite, index);
        addTileAt(sprite, index);
    }

    public override function addSprite(sprite:FinalSprite) {
        sprite._parent = this;
        super.addSprite(sprite);
        addTile(sprite);
    }

    public override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    public override function addBitmap(bitmap:EngineBitmap) {
        addTile(bitmap);
    }

    public override function removeBitmap(bitmap:EngineBitmap) {
        removeTile(bitmap);
    }

    public override function setIndex(sprite:FinalSprite, index:Int) {
        super.setIndex(sprite, index);
        setTileIndex(sprite, index);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.matrix.a = a;
        this.matrix.b = b;
        this.matrix.c = c;
        this.matrix.d = d;
        this.matrix.tx = tx;
        this.matrix.ty = ty;
    }

    public inline function color(r:Int, g:Int, b:Int) {
        #if (openfl >= "6.0.0")
        this.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha);
        #end
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        while(this.numTiles > 0) this.removeTileAt(0);
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.matrix.a = a;
        this.matrix.b = b;
        this.matrix.c = c;
        this.matrix.d = d;
        this.matrix.tx = tx;
        this.matrix.ty = ty;
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        #if (openfl >= "6.0.0")
        this.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha, rAdd, gAdd, bAdd, 0.0);
        #end
    }

    public inline function resetColor() {
        #if (openfl >= "6.0.0")
        this.colorTransform = null;
        #end
    }

    public inline function blend(mode:openfl.display.BlendMode) {
        #if (openfl >= "8.4.0")
        this.blendMode = mode;
        #end
    }

    public inline function resetBlend() {
        #if (openfl >= "8.4.0")
        this.blendMode = null;
        #end
    }
}