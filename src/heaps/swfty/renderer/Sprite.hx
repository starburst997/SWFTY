package heaps.swfty.renderer;

import heaps.swfty.renderer.Layer;
import heaps.swfty.renderer.Text;

import haxe.ds.StringMap;

class HeapsSprite extends BaseSprite {

    public var tile:h2d.Tile;
    public var color:h3d.Vector;

    public var r:Float = 1.0;
    public var g:Float = 1.0;
    public var b:Float = 1.0;

    var _lastAlpha = 1.0;
    var renders:Array<Float->Void>;

    public static inline function create(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String):Sprite {
        return new HeapsSprite(layer, tile, definition, linkage, parent);
    }

    public function new(layer:Layer, ?tile:h2d.Tile, ?definition:MovieClipType, ?linkage:String) {
        this.tile = tile;
        
        renders = [];
        color = new h3d.Vector(1, 1, 1, 1);
        
        super(layer, definition, linkage);
    }

    override function calcAbsPos() {
        super.calcAbsPos();

        // Calculate alpha and color
		if( _parent == null ) {
			color.r = r;
			color.g = g;
			color.b = b;
			color.w = alpha;
		} else {
            color.r = r * _parent.color.r;
			color.g = g * _parent.color.g;
			color.b = b * _parent.color.b;
            color.w = alpha * _parent.color.w;
		}
	}

    public override function addSprite(sprite:Sprite) {
        super.addSprite(sprite);
        addChild(sprite);
    }

    public override function removeSprite(sprite:Sprite) {
        super.removeSprite(sprite);
        sprite.remove();
    }

    public function update(dt:Float) {
        // Hack for alpha change
        if (_lastAlpha != alpha) posChanged = true;
        _lastAlpha = alpha;

        for (sprite in sprites) {
            sprite.update(dt);
        }

        for (f in renders) f(dt);
    }

    public function render(ctx) {
        drawRec(ctx);
    }

    override function draw(ctx) {
        if (tile != null) {
            layer.drawTile(Std.int(MathUtils.x(absX)), Std.int(MathUtils.y(absY)), MathUtils.scaleX(matA, matB, matC, matD), MathUtils.scaleY(matA, matB, matC, matD), MathUtils.rotation(matB, matC, matD), color, tile);
        }
    }

    public function addRender(f:Float->Void) {
        renders.push(f);
    }

    public function removeRender(f:Float->Void) {
        renders.remove(f);
    }

    public function get(name:String):Sprite {
        return if (_childs.exists(name)) {
            _childs.get(name);
        } else {
            if (definition != null) Log.warn('Child: $name does not exists!');
            var sprite = create(layer);
            sprite.name = name;
            _childs.set(name, sprite);
            sprite;
        }
    }

    public function getText(name:String):Text {
        return if (_texts.exists(name)) {
            _texts.get(name);
        } else {
            if (definition != null) Log.warn('Text: $name does not exists!');
            var text = Text.create(layer);
            text.name = name;
            _texts.set(name, text);
            text;
        }
    }
}