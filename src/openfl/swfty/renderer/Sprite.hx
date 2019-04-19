package openfl.swfty.renderer;

typedef EngineSprite = openfl.display.TileContainer;
typedef EngineBitmap = openfl.display.Tile;

@:keepSub // Fix DCE=full
class FinalSprite extends BaseSprite {

    static var pt = new openfl.geom.Point();

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        this.tileset = layer.tileset;

        super(layer, definition, linkage);
    }

    override function getBitmaps():Array<DisplayBitmap> {
        var all = [];
        for (i in 0...numTiles) {
            var tile = getTileAt(i);
            
            all.push(tile);
        }
        return all;
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

    override function calcBounds(?relative:BaseSprite, ?global = false):Rectangle {
        return if (global) {
            var rect = this.getBounds(layer.base);
            {
                x: rect.x * layer.scale,
                y: rect.y * layer.scale,
                width: rect.width * layer.scale,
                height: rect.height * layer.scale
            }
        } else {
            var rect = this.getBounds(relative == null ? this : relative);
            {
                x: rect.x,
                y: rect.y,
                width: rect.width,
                height: rect.height
            }
        }
    }

    override function localToLayer(x:Float = 0.0, y:Float = 0.0):Point {
        pt.x = x;
        pt.y = y;
        pt = this.localToGlobal(pt);

        return { x: pt.x, y: pt.y };
    }

    override function layerToLocal(x:Float, y:Float):Point {
        pt.x = x;
        pt.y = y;
        pt = this.globalToLocal(pt);

        return { x: pt.x, y: pt.y };
    }

    override function hasParent():Bool {
        return this.parent != null;
    }

    override function top() {
        if (this.parent != null) parent.setTileIndex(this, parent.numTiles - 1);
    }

    override function bottom() {
        if (this.parent != null) parent.setTileIndex(this, 0);
    }

    override function addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        super.addSpriteAt(sprite, index);
        addTileAt(sprite, index);
        sprite._parent = this;
    }

    override function addSprite(sprite:FinalSprite, addName = true) {
        super.addSprite(sprite, addName);

        addTile(sprite);
        sprite._parent = this;
    }

    override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    override function removeFromParent() {
        if (this._parent != null) _parent.removeSprite(this);
    }

    override function addBitmap(bitmap:EngineBitmap) {
        addTile(bitmap);
    }

    override function removeBitmap(bitmap:EngineBitmap) {
        removeTile(bitmap);
    }

    override function setIndex(sprite:FinalSprite, index:Int) {
        super.setIndex(sprite, index);
        setTileIndex(sprite, index);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, visible)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        // TODO: Don't trust openfl matrix, it seems like scaleY doesn't work
        //this.matrix.a = a;
        //this.matrix.b = b;
        //this.matrix.c = c;
        //this.matrix.d = d;
        //this.matrix.tx = tx;
        //this.matrix.ty = ty;

        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(a, b, c, d) / Math.PI * 180;
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
        // TODO: Don't trust openfl matrix, it seems like scaleY doesn't work
        //this.matrix.a = a;
        //this.matrix.b = b;
        //this.matrix.c = c;
        //this.matrix.d = d;
        //this.matrix.tx = tx;
        //this.matrix.ty = ty;

        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(a, b, c, d) / Math.PI * 180;
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