package openfl.swfty.renderer;

import openfl.geom.Matrix;
import openfl.display.Tile;

typedef EngineSprite = openfl.display.TileContainer;
typedef EngineBitmap = openfl.display.Tile;

@:keepSub // Fix DCE=full
class FinalSprite extends BaseSprite {

    static var pt = new openfl.geom.Point();

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String, ?debug = false) {
        return new FinalSprite(layer, definition, linkage, debug);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String, ?debug = false) {
        super(layer, definition, linkage, debug);

        finalSprite = this;
        
        this.tileset = layer.tileset;

        load(definition);
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

    override function calcBounds(?relative:FinalSprite, ?global = false):Rectangle {
        var bounds:Rectangle = if (global) {
            if (forceBounds != null) {
                var pt = localToLayer(forceBounds.x, forceBounds.y, 1);
                var pt2 = localToLayer(forceBounds.x + forceBounds.width, forceBounds.y + forceBounds.height, 2);

                {
                    x: pt.x,
                    y: pt.y,
                    width: pt2.x - pt.x,
                    height: pt2.y - pt.y
                }
            } else {
                var rect = _getBounds(layer.base);

                // TODO: There isn't any rotation done on "base", so this works as long as we don't do any complex transform

                #if dev
                //if (rect.width <= 0 || rect.height <= 0) trace('Calc bounds bad values!!!!! $_name');
                #end

                {
                    x: rect.x * layer.base.scaleX,
                    y: rect.y * layer.base.scaleY,
                    width: rect.width * layer.base.scaleX,
                    height: rect.height * layer.base.scaleY
                }
            }

        } else {
            if (relative == null) relative = this;
            
            if (forceBounds != null) {
                var pt = localToLayer(forceBounds.x + forceBounds.width * (scaleX < 0 ? 1 : 0), forceBounds.y + forceBounds.height * (scaleY < 0 ? 1 : 0), 1);
                var pt2 = localToLayer(forceBounds.x + forceBounds.width * (scaleX < 0 ? 0 : 1), forceBounds.y + forceBounds.height * (scaleY < 0 ? 0 : 1), 2);
                
                pt = relative.layerToLocal(pt.x, pt.y, 1);
                pt2 = relative.layerToLocal(pt2.x, pt2.y, 2);
                
                {
                    x: pt.x,
                    y: pt.y,
                    width: pt2.x - pt.x,
                    height: pt2.y - pt.y
                }
            } else {
                var rect = _getBounds(relative);

                #if dev
                //if (rect.width <= 0 || rect.height <= 0) trace('Calc bounds bad values!!!!! $_name');
                #end

                {
                    x: rect.x,
                    y: rect.y,
                    width: rect.width,
                    height: rect.height
                }
            }
        }

        return bounds;

        /*return if (_mask != null || parentMask != null) {

            var mask:Rectangle = if (_mask != null) {
                getMaskRectangle();
            } else {
                parentMask.getMaskRectangle();
            }

            if (global) {

                if (mask.contains(bounds)) {
                    bounds;
                } else if (mask.intersects(bounds)) {
                    mask.getIntersect(bounds, bounds);
                } else {
                    bounds.width = 0;
                    bounds.height = 0;
                    bounds;
                }

            } else {

                var pt1 = relative.layerToLocal(mask.x, mask.y, 1);
                var pt2 = relative.layerToLocal(mask.x + mask.width, mask.y + mask.height, 2);

                mask = Rectangle.temp.set(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);

                if (mask.contains(bounds)) {
                    bounds;
                } else if (mask.intersects(bounds)) {
                    mask.getIntersect(bounds, bounds);
                } else {
                    bounds.width = 0;
                    bounds.height = 0;
                    bounds;
                }
            }
        } else {
            bounds;
        }*/
    }

    /* These functions needs cleanup, they were taken from openfl class and modified */

    function _findTileset() {
        return if (tileset != null) {
			tileset;
		} else if (_parent != null) {
			var tileset = _parent._findTileset();
			this.tileset = tileset;
			tileset;
		} else {
			null;
		}
	}

    var transformId = -1;
    var tempMatrix:Matrix = null;
	var tempTransform:Matrix = null;
	public function _getWorldTransform():Matrix {
		return if (layer.updateID == transformId && tempTransform != null) {
			tempTransform;
		} else {
			transformId = layer.updateID;

			if (tempMatrix == null) tempMatrix = new Matrix();
			tempMatrix.copyFrom(matrix);
			var retval = tempMatrix;
			
			if (_parent != null) {
				retval.concat(_parent._getWorldTransform());
			}

			if (tempTransform == null) tempTransform = new Matrix();
			tempTransform.copyFrom(retval);

			retval;
		}
	}

    var tempRectangle:openfl.geom.Rectangle = null;
	var tempMatrix1:Matrix = null;
	var tempMatrix2:Matrix = null;

    var tempRectContainer:openfl.geom.Rectangle = null;
	function _getBounds (targetCoordinateSpace:FinalSprite):openfl.geom.Rectangle {
		if (tempRectContainer == null) tempRectContainer = new openfl.geom.Rectangle();
		tempRectContainer.setTo(0, 0, 0, 0);
		var result = tempRectContainer;

		var rect = null;
		
        inline function union (rect:openfl.geom.Rectangle, toUnion:openfl.geom.Rectangle):openfl.geom.Rectangle {
            return if (rect.width == 0 || rect.height == 0) {
                rect.setTo(toUnion.x, toUnion.y, toUnion.width, toUnion.height);
                rect;
            } else if (toUnion.width == 0 || toUnion.height == 0) {
                rect;
            } else {
                var x0 = rect.x > toUnion.x ? toUnion.x : rect.x;
                var x1 = rect.right < toUnion.right ? toUnion.right : rect.right;
                var y0 = rect.y > toUnion.y ? toUnion.y : rect.y;
                var y1 = rect.bottom < toUnion.bottom ? toUnion.bottom : rect.bottom;
                
                rect.setTo(x0, y0, x1 - x0, y1 - y0);
                rect;
            }
        }

        // Bounds on shapes then do children
        for (shape in _bitmaps) {
            rect = shape._getBounds(targetCoordinateSpace);
            result = union(result, rect);
        }

		for (sprite in _sprites) /*if (tile.visible)*/ {
			rect = sprite._getBounds(targetCoordinateSpace);
			result = union(result, rect);
		}

		return result;
	}

    override function localToLayer(x:Float = 0.0, y:Float = 0.0, temp = 0):Point {
        var pt:Point = temp == 2 ? tempPt2 : temp == 1 ? tempPt1 : { x: 0, y: 0 };
        
        var matrix = _getWorldTransform();
        pt.x = x * matrix.a + y * matrix.c + matrix.tx;
        pt.y = x * matrix.b + y * matrix.d + matrix.ty;

        return pt;
    }

    override function layerToLocal(x:Float, y:Float, temp = 0):Point {
        var pt:Point = temp == 2 ? tempPt2 : temp == 1 ? tempPt1 : { x: 0, y: 0 };
        
        var matrix = _getWorldTransform();
        var norm = matrix.a * matrix.d - matrix.b * matrix.c;
        
        if (norm == 0) {
            pt.x = -matrix.tx;
            pt.y = -matrix.ty;
        } else {
            pt.x = (1.0 / norm) * (matrix.c * (matrix.ty - y) + matrix.d * (x - matrix.tx));
            pt.y = (1.0 / norm) * (matrix.a * (y - matrix.ty) + matrix.b * (matrix.tx - x));
        }
        
        return pt;
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

    override function addSpriteAt(sprite:FinalSprite, index:Int = 0, immediate = true) {
        super.addSpriteAt(sprite, index, immediate);
        sprite._parent = this;
    }

    override function addSprite(sprite:FinalSprite, addName = true, immediate = true) {
        super.addSprite(sprite, addName, immediate);
        sprite._parent = this;
    }

    override function _addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        super._addSpriteAt(sprite, index);
        addTileAt(sprite, index);
    }

    override function _addSprite(sprite:FinalSprite) {
        super._addSprite(sprite);
        addTile(sprite);
    }

    override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    override function removeFromParent() {
        if (this._parent != null) _parent.removeSprite(this);
    }

    override function addBitmap(bitmap:DisplayBitmap) {
        super.addBitmap(bitmap);
        addTile(bitmap);
    }

    override function removeBitmap(bitmap:DisplayBitmap) {
        super.removeBitmap(bitmap);
        removeTile(bitmap);
    }

    override function setIndex(sprite:FinalSprite, index:Int) {
        super.setIndex(sprite, index);
        setTileIndex(sprite, index);
    }
}

class DisplayBitmap extends EngineBitmap {

    var _layer:BaseLayer;
    var _parent:FinalSprite;

    public static inline function create(layer:BaseLayer, parent:FinalSprite, id:Int, og:Bool = false):DisplayBitmap {
        return new DisplayBitmap(layer.getTile(id), layer, parent);
    }

    public function new(id:DisplayTile, layer:BaseLayer, parent:FinalSprite) {
        super(id);

        _layer = layer;
        _parent = parent;
    }

    var tempRectangle:openfl.geom.Rectangle = null;
	var tempMatrix1:Matrix = null;
	var tempMatrix2:Matrix = null;

    var tempRectContainer:openfl.geom.Rectangle = null;

    var tempRect:openfl.geom.Rectangle;
	inline function _getRect (id:Int, ?temp:openfl.geom.Rectangle):openfl.geom.Rectangle {
        var tileset = _findTileset();

		if (temp == null) {
			if (tempRect == null) tempRect = new openfl.geom.Rectangle();
			temp = tempRect;
		}

		@:privateAccess return if (id < tileset.__data.length && id >= 0) {
			temp.setTo(tileset.__data[id].x, tileset.__data[id].y, tileset.__data[id].width, tileset.__data[id].height);
			temp;
		} else {
			null;
		}
	}

    var transformId = -1;
    var tempMatrix:Matrix = null;
	var tempTransform:Matrix = null;
	function _getWorldTransform():Matrix {
		return if (_layer.updateID == transformId && tempTransform != null) {
			tempTransform;
		} else {
			transformId = _layer.updateID;

			if (tempMatrix == null) tempMatrix = new Matrix();
			tempMatrix.copyFrom(matrix);
			var retval = tempMatrix;
			
			if (_parent != null) {
				retval.concat(_parent._getWorldTransform());
			}

			if (tempTransform == null) tempTransform = new Matrix();
			tempTransform.copyFrom(retval);

			retval;
		}
	}

    public function _getBounds(targetCoordinateSpace:FinalSprite):openfl.geom.Rectangle {
		if (tempRectangle == null) tempRectangle = new openfl.geom.Rectangle();
		tempRectangle.setTo(0, 0, 1, 1);
		
		var result:openfl.geom.Rectangle;

		if (tileset == null) {
			var parentTileset = _findTileset();
			if (parentTileset == null) return tempRectangle;
			result = _getRect(id, tempRectangle);
			if (result == null) return tempRectangle;
			
			tileset = parentTileset;
		} else {
			result = _getRect(id, tempRectangle);
		}

		// TODO: How is this possible?!?!?!?! getRect return null? id out of bounds!?!?
		if (result == null) return tempRectangle;

		result.x = 0;
		result.y = 0;

		if (tempMatrix1 == null) tempMatrix1 = new Matrix();
		tempMatrix1.identity();

		var matrix = tempMatrix1;
		
		if (targetCoordinateSpace != null) {
			matrix.copyFrom(_getWorldTransform());
			
			if (tempMatrix2 == null) tempMatrix2 = new Matrix();
			tempMatrix2.identity();

			var targetMatrix = tempMatrix2;
			
			targetMatrix.copyFrom(targetCoordinateSpace._getWorldTransform());
			targetMatrix.invert();
			
			matrix.concat(targetMatrix);
			
		} else {
			matrix.copyFrom(_getWorldTransform());
		}
		
		#if flash
		inline function __transform(rect:openfl.geom.Rectangle, m:Matrix):Void {
			var tx0 = m.a * rect.x + m.c * rect.y;
			var tx1 = tx0;
			var ty0 = m.b * rect.x + m.d * rect.y;
			var ty1 = ty0;
			
			var tx = m.a * (rect.x + rect.width) + m.c * rect.y;
			var ty = m.b * (rect.x + rect.width) + m.d * rect.y;
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			tx = m.a * (rect.x + rect.width) + m.c * (rect.y + rect.height);
			ty = m.b * (rect.x + rect.width) + m.d * (rect.y + rect.height);
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			tx = m.a * rect.x + m.c * (rect.y + rect.height);
			ty = m.b * rect.x + m.d * (rect.y + rect.height);
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			rect.setTo(tx0 + m.tx, ty0 + m.ty, tx1 - tx0, ty1 - ty0);
		}

		__transform(result, matrix);
		#else
		@:privateAccess result.__transform(result, matrix);
		#end
	
		return result;
	}

    public function _findTileset(?tile:openfl.display.Tile) {
		if (tile == null) tile = this;
        return if (tile.tileset != null) {
			tile.tileset;
		} else if (tile.parent != null) {
			var tileset = _findTileset(tile.parent);
			tile.tileset = tileset;
			tileset;
		} else {
			null;
		}
	}

    inline function getTileset() {
        return if (this.tileset != null) {
            this.tileset;
        } else if (this.parent != null) {
            @:privateAccess var tileset = _findTileset(this.parent);
            this.tileset = tileset;
            tileset;
        } else {
            null;
        }
    }

    inline function getData(id:DisplayTile) {
        var tileset = getTileset();
        if (tileset == null) return null;
        
        @:privateAccess var tiles = tileset.__data;
        return if (this.id < tiles.length && this.id >= 0) {
            tiles[this.id];
        } else {
            null;
        }
    }

    // TODO: Use temp Rectangle
    public inline function getTile(id:DisplayTile):Rectangle {
        var data = getData(id);
        return if (data == null) {
            x: 0,
            y: 0,
            width: 1,
            height: 1
        } else {
            x: data.x,
            y: data.y,
            width: data.width,
            height: data.height
        }
    }

    public var width(get, never):Float;
    inline function get_width() {
        var data = getData(this.id);
        return if (data != null) {
            data.width * this.scaleX;
        } else {
            1;
        }
    }

    public var height(get, never):Float;
    inline function get_height() {
        var data = getData(this.id);
        return if (data != null) {
            data.height * this.scaleY;
        } else {
            1;
        }
    }

    // TODO: Use temp Rectangle
    public var tile(get, never):Rectangle;
    function get_tile():Rectangle {
        var data = getData(this.id);
        return if (data == null) {
            x: 0,
            y: 0,
            width: 1,
            height: 1
        } else {
            x: data.x,
            y: data.y,
            width: data.width,
            height: data.height
        };
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, scaleX:Float = 1.0, scaleY:Float = 1.0) {
        // TODO: Don't trust openfl matrix, it seems like scaleY doesn't work
        //this.matrix.a = a;
        //this.matrix.b = b;
        //this.matrix.c = c;
        //this.matrix.d = d;
        //this.matrix.tx = tx;
        //this.matrix.ty = ty;

        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d) / scaleX;
        this.scaleY = MathUtils.scaleY(a, b, c, d) / scaleY;
        this.rotation = MathUtils.rotation(a, b, c, d) / Math.PI * 180;
    }

    public inline function color(r:Int, g:Int, b:Int) {
        #if (openfl >= "6.0.0")
        //this.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha);
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
        //this.colorTransform = new openfl.geom.ColorTransform(r / 255.0, g / 255.0, b / 255.0, this.alpha, rAdd, gAdd, bAdd, 0.0);
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