package swfty.renderer;

import haxe.ds.StringMap;

import swfty.renderer.BaseLayer;

using swfty.extra.Timer;
using swfty.extra.Tween;

enum SpriteType {
    Unknown;
    Display(sprite:Sprite);
    Text(text:Text);
}

@:allow(swfty.renderer.BaseSprite)
class BaseSprite extends EngineSprite {

    static var COUNTER = 0;

    var disposed = false;

    public var type:SpriteType = Unknown;

    public var og:Bool = false;

    public var uuid:Int = COUNTER++;

    public var _width(get, set):Float;
    public var _height(get, set):Float;

    public var bounds(get, null):Rectangle;

    public var layer:Layer;
    var _layer:BaseLayer;

    public var countVisible = true;
    public var loaded = false;
    public var debug = false;
    public var updating = false;
    public var canDispose = false;
    public var rendered = false;
    var _rendered = 0;

    public var renderID:Int = 0;

    // TODO: Only used on heaps, kind of a hack, I think saving the ColorType instead might solve this
    public var r:Float = 1.0;
    public var g:Float = 1.0;
    public var b:Float = 1.0;

    // TODO: I don't like having this as part of BaseSprite, might remove...
    public var interactive:Bool = false;

    // For reload if definition didn't exists
    var _linkage:String;

    // Force a certain dimension, usefull for Text
    var forceBounds:Rectangle = null;

    // Using underscore to prevent var clasing with base class
    // TODO: All private var should have an underscore?
    var _name(default, set):String;
    var _sprites:Array<FinalSprite>;
    var _bitmaps:Array<EngineBitmap>;
    var _names:StringMap<FinalSprite>;
    var _texts:StringMap<FinalText>;
    var _definition:Null<MovieClipType>;
    var _bounds:Rectangle;

    var _mask(default, set):Rectangle = null;
    function set__mask(value:Rectangle) {
        _mask = value;
        return value;
    }

    var _parent(default, set):FinalSprite;
    inline function set__parent(value:FinalSprite) {
        if (_parent == null && _visible) {
            _layer.wake();
        }

        _parent = value;
        
        if (value == null) for (f in _removed) f();
        else for (f in _added) f();

        return value;
    }

    var _visible(default, set):Bool = true;
    inline function set__visible(value:Bool) {
        if (value) _layer.wake();

        _visible = value;
        visible = value;
        return value;
    }

    // Mask stuff
    var isMasked = false;
    var maskMap:Map<EngineBitmap, EngineBitmap> = new Map();
    
    var parentMask:BaseSprite = null;
    var __mask:Rectangle = null;
    
    var firstMask = 0;

    // Keep some original values that can be usefull
    public var originalX:Float = 0.0;
    public var originalY:Float = 0.0;
    public var originalScaleX:Float = 1.0;
    public var originalScaleY:Float = 1.0;
    public var originalAlpha:Float = 1.0;
    public var originalRotation:Float = 0.0;
    public var originalVisible:Bool = false;

    // Being able to add a render loop is a pretty nice tool
    // The map allows you to give it a name so you can easily remove all render loop from a specific name 
    // TODO: Would using an IntMap bring more performance?
    var _renders:Array<Float->Void>;
    var _rendersMap:StringMap<Array<Float->Void>>;
    
    var _added:Array<Void->Void>;
    var _removed:Array<Void->Void>;

    var _pruneAdded:Array<Void->Void>;
    var _pruneRemoved:Array<Void->Void>;
    var _pruneRenders:Array<Float->Void>;
    var _pruneSprites:Array<FinalSprite>;

    // Prevent creating too many objects per frame
    @:isVar var tempPt1(get, null):Point;
    inline function get_tempPt1() {
        if (tempPt1 == null) tempPt1 = { x: 0, y: 0 };
        return tempPt1;
    }

    @:isVar var tempPt2(get, null):Point;
    inline function get_tempPt2() {
        if (tempPt2 == null) tempPt2 = { x: 0, y: 0 };
        return tempPt2;
    }

    @:isVar var tempRect1(get, null):Rectangle;
    inline function get_tempRect1() {
        if (tempRect1 == null) tempRect1 = { x: 0, y: 0, width: 1, height: 1 };
        return tempRect1;
    }

    @:isVar var tempRect2(get, null):Rectangle;
    inline function get_tempRect2() {
        if (tempRect2 == null) tempRect2 = { x: 0, y: 0, width: 1, height: 1 };
        return tempRect2;
    }

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String, ?debug = false) {
        super();

        this.debug = debug;
        this.layer = layer;
        this._layer = layer;
        _linkage = linkage;

        _added = [];
        _removed = [];

        _renders = [];
        _rendersMap = new StringMap();

        _sprites = [];
        _bitmaps = [];
        _names = new StringMap();
        _texts = new StringMap();

        _pruneAdded = [];
        _pruneRemoved = [];
        _pruneRenders = [];
        _pruneSprites = [];

        load(definition);
    }

    public inline function getTempPt(x:Float = 0, y:Float = 0) {
        tempPt1.x = x;
        tempPt1.y = y;
        return tempPt1;
    }

    function set__name(name:String) {
        if (_parent != null && _name != name) {
            _parent._names.remove(_name);
        }
        
        _name = name;
        return _name;
    }

    // TODO: Not super optimized, usually getting the X we would also get the Y so we could cache it for one frame
    public inline function getMouseX():Float {
        return layerToLocal(layer.mouse.x, layer.mouse.y, 1).x;
    }

    public inline function getMouseY():Float {
        return layerToLocal(layer.mouse.x, layer.mouse.y, 1).y;
    }

    public function calcBounds(?relative:BaseSprite, ?global = false):Rectangle {
        throw 'Not implemented';
    }

    public function hasParent():Bool {
        throw 'Not implemented';
    }

    public function top() {
        throw 'Not implemented';
    }

    public function bottom() {
        throw 'Not implemented';
    }

    inline function get_bounds() {
        if (_bounds == null) {
            var rect = calcBounds();

            // Prevent caching invalid bounds
            if (rect.width > 0 || rect.height > 0) {
                return _bounds = rect;
            } else {
                return rect;
            }
        }
        return _bounds;
    }

    public function addEmptyRect(x:Float, y:Float, width:Float, height:Float) {
        var empty = layer.create('Empty');
        empty.x = x;
        empty.y = y;
        empty.scaleX = width;
        empty.scaleY = height;
        addSprite(empty);
        return empty;
    }

    public inline function setBounds(x:Float, y:Float, width:Float, height:Float) {
        if (_bounds == null) 
            _bounds = {x: x, y: y, width: width, height: height};
        else {
            _bounds.x = x;
            _bounds.y = y;
            _bounds.width = width;
            _bounds.height = height;
        }

        forceBounds = _bounds;
    }

    public inline function removeBounds() {
        forceBounds = null;
        _bounds = null;
    }

    public inline function hasForceBounds() {
        return forceBounds != null;
    }

    function get__width():Float {
        return bounds.width * scaleX;
    }

    function set__width(width:Float) {
        scaleX = width / bounds.width;
        return width;
    }

    function get__height():Float {
        return bounds.height * scaleY;
    }

    function set__height(height:Float) {
        scaleY = height / bounds.height;
        return height;
    }

    function getAllBitmaps():Array<DisplayBitmap> {
        var all = getBitmaps();
        for (sprite in _sprites) {
            all = all.concat(sprite.getBitmaps());
        }
        return all;
    }

    function getBitmaps():Array<DisplayBitmap> {
        throw 'Not implemented';
    }

    public function colorize(color:UInt) {
        for (bitmap in getAllBitmaps()) {
            bitmap.color(color >> 16, (color & 0xFF00) >> 8, color & 0xFF);
        }
    }

    // TODO: Change "add" to "on" ?
    public inline function addAdded(f:Void->Void) {
        _added.push(f);
    }

    public inline function addRemoved(f:Void->Void) {
        _removed.push(f);
    }

    public inline function removeAdded(f:Void->Void) {
        _pruneAdded.push(f);
    }

    public inline function removeRemoved(f:Void->Void) {
        _pruneRemoved.push(f);
    }

    public inline function addRender(?name:String, f:Float->Void, ?priority = false) {
        if (priority) _renders.unshift(f);
        else _renders.push(f);
        
        if (name != null) {
            if (!_rendersMap.exists(name)) _rendersMap.set(name, []);
            _rendersMap.get(name).push(f);
        }
    }

    public inline function addRenderNow(?name:String, f:Float->Void, ?priority = false) {
        addRender(name, f, priority);
        f(0.0);
    }

    public inline function removeRender(?name:String, ?f:Float->Void) {
        if (f != null) {
            _pruneRenders.push(f);

            if (_rendersMap.exists(name)) {
                _rendersMap.get(name).remove(f);
            }
        } else if (name != null && _rendersMap.exists(name)) {
            for (f in _rendersMap.get(name)) {
                _pruneRenders.push(f);
            }
            
            _rendersMap.remove(name);
        }
    }

    @:isVar var tempRectMask(get, null):Rectangle;
    inline function get_tempRectMask() {
        if (tempRectMask == null) tempRectMask = { x: 0, y: 0, width: 1, height: 1 };
        return tempRectMask;
    }
    public function getMaskRectangle():Rectangle {
        return if (__mask != null) {
            __mask;
        } else if (_mask == null) {
            __mask = {
                x: 0.0,
                y: 0.0,
                width: 128.0,
                height: 128.0
            };

            __mask;
        } else {
            // Convert to layer bounds
            var pt = localToLayer(_mask.x, _mask.y, 1);
            var pt2 = localToLayer(_mask.x + _mask.width, _mask.y + _mask.height, 2);
            
            var rect = tempRectMask.set(pt.x, pt.y, pt2.x - pt.x, pt2.y - pt.y);
            if (parentMask != null && !parentMask.getMaskRectangle().contains(rect)) {
                __mask = parentMask.getMaskRectangle().getIntersect(rect, rect);
            } else {
                __mask = rect;
            }

            __mask;
        }
    }

    // Basic mask implementation, does not work with rotation or negative scaling
    // TODO: Rotation, negative scaling
    function calculateMask(dt:Float) {
        if (parentMask == null && _mask == null) return;
        
        var mask = if (_mask != null) {
            getMaskRectangle();
        } else {
            parentMask.getMaskRectangle();
        }

        for (bitmap in _bitmaps) {
            var display:DisplayBitmap = bitmap;

            // Keep reference of the original tile 
            inline function getDupe() {
                return if (!maskMap.exists(bitmap)) {
                    var tile = display.tile;
                    var dupe:DisplayBitmap = layer.getTempBitmap(Std.int(tile.x), Std.int(tile.y), Std.int(tile.width), Std.int(tile.height));

                    var index = this.getTileIndex(bitmap);
                    this.addTileAt(dupe, index + 1);
                    this.removeTile(bitmap);

                    maskMap.set(bitmap, dupe);
                    dupe;
                } else {
                    maskMap.get(bitmap);
                }
            }

            inline function removeDupe() {
                if (maskMap.exists(bitmap)) {
                    var dupe = maskMap.get(bitmap);

                    var index = this.getTileIndex(dupe);
                    this.addTileAt(bitmap, index + 1);
                    this.removeTile(dupe);

                    layer.disposeTempBitmap(dupe);
                    maskMap.remove(bitmap);
                }
            }

            var pt = localToLayer(display.x, display.y, 1);
            var pt2 = localToLayer(display.x + display.width, display.y + display.height, 2);
            var bounds = tempRect1.set(pt.x, pt.y, pt2.x - pt.x, pt2.y - pt.y);

            if (mask.contains(bounds)) {
                // We're completely inside
                display.visible = true;
                removeDupe();
            } else if (mask.intersects(bounds)) {

                var dupe = getDupe();
                
                // Figure out part that is visible
                var intersect = mask.getIntersect(bounds);
                
                // Get a temp bitmap that will only represents a part of it
                var tile = display.tile;
                var x = (intersect.x - bounds.x) / bounds.width * tile.width;
                var y = (intersect.y - bounds.y) / bounds.height * tile.height;
                var width = intersect.width / bounds.width * tile.width;
                var height = intersect.height / bounds.height * tile.height;

                layer.updateDisplayTile(dupe.id, tile.x + x, tile.y + y, width, height);

                // Set coordinate / scaling          
                var local = layerToLocal(intersect.x, intersect.y, 1);

                dupe.x = local.x;
                dupe.y = local.y;
                dupe.scaleX = bitmap.scaleX;
                dupe.scaleY = bitmap.scaleY;
                dupe.alpha = bitmap.alpha;

            } else {
                // We're completely out, so invisible
                // TODO: If we remove the tile, we loose the "index"
                display.visible = false;
                removeDupe();
            }
        }
    }

    public function update(dt:Float, ?mask:BaseSprite) {
        // TODO: Wonder if that's the best solution... If it's invisible I wouldn't want anything called...
        //       Maybe sleep() / awake() sprite?
        //if (!_visible) return;

        if (firstUpdate) {
            //firstUpdate = false;
            //visible = tempVisible;
        }

        parentMask = mask;

        if (_mask != null) {
            mask = this;
        }

        __mask = null;

        updating = true;

        if (countVisible) _layer.hasVisible = true;

        renderID = layer.spriteRenderID++;

        for (i in 0..._sprites.length) {
            var sprite = _sprites[_sprites.length - 1 - i];
            sprite.update(dt, mask);
        }

        if (loaded) for (f in _renders) f(dt);

        if (mask != null) {
            if (!isMasked) {
                isMasked = true;
                for (bitmap in _bitmaps) bitmap.visible = false;

                layer.addPostPostRender(calculateMask);
            }
        } else if (isMasked) {
            isMasked = false;
            layer.removePostPostRender(calculateMask);
        }

        // TODO: Migh be interesting to move to an entity architecture, most of the time these wouldn't be used
        //       But it's kinda cheap operation, if it really impact performance we can have a "Particle" class

        if (_pruneAdded.length > 0) {
            for (f in _pruneAdded) _added.remove(f);
            _pruneAdded = [];
        }

        if (_pruneRemoved.length > 0) {
            for (f in _pruneRemoved) _removed.remove(f);
            _pruneRemoved = [];
        }

        if (_pruneRenders.length > 0) {
            for (f in _pruneRenders) _renders.remove(f);
            _pruneRenders = [];
        }

        if (_pruneSprites.length > 0) {
            for (s in _pruneSprites) _sprites.remove(s);
            _pruneSprites = [];
        }

        updating = false;

        if (!rendered && loaded && ++_rendered >= 2) {
            rendered = true;
        }

        if (canDispose) {
            canDispose = false;
            dispose();
        }
    }

    public inline function display():DisplaySprite {
        return this;
    }

    // This is a "soft" clear, it won't call any event
    function removeAll() {
        display().removeAll();

        for (shape in maskMap) {
            layer.disposeTempBitmap(shape);
        }

        maskMap = new Map();

        _sprites = [];
        _bitmaps = [];
    }

    public function load(definition:MovieClipType) {
        _definition = definition;
        if (definition != null) _linkage = definition.name;
        
        var childs = _sprites;
        var skipChilds = [];

        // Clear all childrens
        removeAll();

        if (definition == null) return;

        var scale = layer.getInternalScale();

        // Create children
        var updateVisible = true, updatePosition = true, updateScale = true, updateRotation = true, updateAlpha = true;
        for (child in definition.children) {
            
            if (!loaded) {
                // TODO: Probably not the best way to do it.... Might as well create getter for properties and not override the EngineSprite class
                //       but keep it as a var, this way I could turn a switch on whenever a propery has been changed by the user rather than the library
                updateVisible = true;
                updatePosition = true;
                updateScale = true;
                updateRotation = true;
                updateAlpha = true;
            }
            
            if (child.text != null) {
                
                // Scaling TextField is tricky, we scaleY back to 1.0 and scale the Font Size instead
                function adjustTransform(text:FinalText) {
                    // If a previous sprite existed with same name
                    if (!child.name.empty() && _names.exists(child.name) && _names.get(child.name) != text) {
                        var textSprite = _names.get(child.name);

                        if (!loaded) {
                            if (!textSprite._visible) updateVisible = false;
                            if (textSprite.x != 0 || textSprite.y != 0) updatePosition = false;
                            if (textSprite.scaleX != 1 || textSprite.scaleY != 1) updateScale = false;
                            if (textSprite.rotation != 0) updateRotation = false;
                            if (textSprite.alpha != 1) updateAlpha = false;
                        }

                        text.copy(textSprite);
                        _names.set(child.name, text);

                        skipChilds.push(textSprite);
                        childs.remove(textSprite);
                        textSprite.dispose();
                    }

                    if (updatePosition && updateScale && updateRotation) {
                        var scaleX = MathUtils.scaleX(child.a, child.b, child.c, child.d);
                        var scaleY = MathUtils.scaleY(child.a, child.b, child.c, child.d);

                        text.display().transform(child.a, child.b, child.c, child.d, child.tx + child.text.x * scaleX, child.ty + child.text.y * scaleY);

                        // TODO: Maybe switch this back, it seemed more accurate to certain aspect
                        //text.scaleFont = text.scaleY;
                        //text.scaleX = text.scaleX / text.scaleY;
                        //text.scaleY = 1.0;
                    }
                }
                
                var text = if (!child.name.empty() && _texts.exists(child.name)) {
                    var text = _texts.get(child.name);

                    if (!loaded) {
                        if (!text._visible) updateVisible = false;
                        if (text.x != 0 || text.y != 0) updatePosition = false;
                        if (text.scaleX != 1 || text.scaleY != 1) updateScale = false;
                        if (text.rotation != 0) updateRotation = false;
                        if (text.alpha != 1) updateAlpha = false;
                    }

                    adjustTransform(text);
                    text.loadText(child.text);

                    text.refresh();
                    for (sprite in text._sprites) {
                        sprite.refresh();
                    }

                    text;
                } else {
                    var text = FinalText.create(layer);
                    
                    adjustTransform(text);
                    text.loadText(child.text);

                    if (!child.name.empty()) {
                        text._name = child.name;
                        _texts.set(child.name, text);
                    }
                    text;
                }
                
                text.og = true;
                text.loaded = true;

                if (updateAlpha) text.alpha = child.alpha;
                if (updateVisible) text._visible = child.visible;

                // Save original values
                if (updatePosition) {
                    text.originalX = text.x;
                    text.originalY = text.y;
                }

                if (updateScale) {
                    text.originalScaleX = text.scaleX;
                    text.originalScaleY = text.scaleY;
                }

                if (updateRotation) text.originalRotation = text.rotation;
                if (updateAlpha) text.originalAlpha = text.alpha;
                if (updateVisible) text.originalVisible = text._visible;

                addSprite(text);
            } else {
                var sprite:FinalSprite = if (!child.name.empty() && _names.exists(child.name)) {

                    var sprite:FinalSprite = _names.get(child.name);

                    if (!loaded) {
                        if (!sprite._visible) updateVisible = false;
                        if (sprite.x != 0 || sprite.y != 0) updatePosition = false;
                        if (sprite.scaleX != 1 || sprite.scaleY != 1) updateScale = false;
                        if (sprite.rotation != 0) updateRotation = false;
                        if (sprite.alpha != 1) updateAlpha = false;
                    }

                    sprite.refresh();
                    sprite.load(child.mc);

                    sprite;
                } else {
                    var sprite:FinalSprite = FinalSprite.create(layer, child.mc);
                    if (!child.name.empty()) {
                        sprite._name = child.name;
                        _names.set(child.name, sprite);
                    }
                    sprite;
                }

                sprite.og = true;

                if (updatePosition && updateScale && updateRotation) sprite.display().transform(child.a, child.b, child.c, child.d, child.tx, child.ty);
                if (updateVisible) sprite._visible = child.visible;

                // This will add drawCalls, so big no no unless you really want them
                #if allowBlendMode
                if (mode != Normal && mode != null) {
                    sprite.blend(child.blendMode);
                } else {
                    sprite.resetBlend();
                }
                #end

                if (child.color != null) {
                    var color = child.color;
                    sprite.display().color(color.r, color.g, color.b, color.rAdd, color.gAdd, color.bAdd);
                } else {
                    sprite.display().resetColor();
                }

                if (updateAlpha) sprite.alpha = child.alpha;

                for (shape in child.shapes) {
                    var tile = _layer.createBitmap(shape.bitmap.id, true);
                    tile.transform(shape.a, shape.b, shape.c, shape.d, shape.tx, shape.ty, shape.bitmap.originalWidth > 0 && shape.bitmap.width > 0 ? shape.bitmap.width / shape.bitmap.originalWidth : scale, shape.bitmap.originalHeight > 0 && shape.bitmap.height > 0 ? shape.bitmap.height / shape.bitmap.originalHeight : scale);
                    sprite.addBitmap(tile);
                }

                // Save original values
                if (updatePosition) {
                    sprite.originalX = sprite.x;
                    sprite.originalY = sprite.y;
                }

                if (updateScale) {
                    sprite.originalScaleX = sprite.scaleX;
                    sprite.originalScaleY = sprite.scaleY;
                }

                if (updateRotation) sprite.originalRotation = sprite.rotation;
                if (updateAlpha) sprite.originalAlpha = sprite.alpha;
                if (updateVisible) sprite.originalVisible = sprite._visible;

                addSprite(sprite);
            }
        }

        loaded = true;
        
        // Re-add non-og tile
        for (child in childs) {
            if (!child.og) {
                #if dev
                // TODO: This can be triggered by "legit" new sprite with a name added to the display list, need to figure a better way
                if (!child._name.empty() && skipChilds.indexOf(child) == -1) Log.warn('Missing Child: ${child._name} (${layer.path})');
                #end

                child.reload();

                // TODO: Usually non-og sprites are added on top, figure out a better way to preserve order!!
                addSprite(child);
            }
        }
    }

    inline function copy(sprite:BaseSprite) {
        this.x = sprite.x;
        this.y = sprite.y;
        this.scaleX = sprite.scaleX;
        this.scaleY = sprite.scaleY;
        this.rotation = sprite.rotation;
        this.alpha = sprite.alpha;
        this._visible = sprite._visible;

        this._renders = sprite._renders;
        this._rendersMap = sprite._rendersMap;
        
        this._added = sprite._added;
        this._removed = sprite._removed;
    }

    public inline function getParent() {
        return _parent;
    }

    function refresh() {
        // Override if necessary, this is when the texture get replaced by a new one
    }

    public function reload() {
        // We cannot use definition.id because it can change... would've been nice if it was using the "itemID" instead...
        /*if (_definition != null) {
            if (layer.hasDefinition(_definition.id)) {
                var definition = layer.getDefinition(_definition.id);
                load(definition);
            } else {
                Log.warn('Definition does no longer exists: ${_definition.name} (${_definition.id})');
            }
        } else*/ if (_linkage != null) {
            if (_layer.hasMC(_linkage)) {
                var definition = _layer.getMC(_linkage);
                load(definition);
            } else {
                #if dev
                Log.warn('Definition does not exists: ${_linkage} ${layer.path}');
                #end
            }
        } else {
            // Simply reload all sprites
            for (sprite in _sprites) sprite.reload();

            loaded = true;
        }
    }

    public function getIndex(?sprite:FinalSprite) {
        #if dev
        // TODO: Not that big of a deal, but we should compensate and calculate the real index after those child are moved
        //       We can always override this and used the engine's specific way of doing it, should give the correct value
        if (_pruneSprites.length > 0) trace('Error: This value is incorrect!!!!');
        #end
        return _sprites.indexOf(sprite);
    }

    public function addSpriteAt(sprite:FinalSprite, index:Int = 0) {
        sprite.removeFromParent();
        
        if (sprite._name != null) {
            _names.set(sprite._name, sprite);
        }

        _sprites.insert(index, sprite);
        _pruneSprites.remove(sprite);
        
        // TODO: Was that necessary?
        if (!sprite.loaded && sprite.layer.loaded) {
            sprite.reload();
        }
    }

    var tempVisible = false;
    var firstUpdate = false;
    public function addSprite(sprite:FinalSprite, addName = true) {
        sprite.removeFromParent();

        if (addName && sprite._name != null) {
            _names.set(sprite._name, sprite);
        }

        _sprites.push(sprite);
        _pruneSprites.remove(sprite);
        
        // TODO: Was that necessary?
        if (!sprite.loaded && sprite.layer.loaded) {
            sprite.reload();
        }

        // TODO: hack for mask, figure something better
        if (__mask != null) {
            var s:Sprite = sprite;
            var alpha = s.alpha;
            s.alpha = 0.0;

            s.wait(0.1, function() {
                s.tweenAlpha(alpha, 0.2);
            });
        }
    }

    public function removeSprite(sprite:FinalSprite) {
        if (disposed) return;

        if (sprite._name != null) _names.remove(sprite._name);
        _pruneSprites.push(sprite); // TODO: This might screw the "getIndex"
        sprite._parent = null;
    }

    public function setIndex(sprite:FinalSprite, index:Int) {
        if (_sprites.remove(sprite)) {
            _sprites.insert(index, sprite);
        }
    }

    public function removeFromParent() {
        throw 'Not implemented';
    }

    public function addBitmap(shape:EngineBitmap) {
        _bitmaps.push(shape);
    }

    public function removeBitmap(shape:EngineBitmap) {
        _bitmaps.remove(shape);

        if (maskMap.exists(shape)) {
            var dupe = maskMap.get(shape);
            this.removeTile(dupe);
            layer.disposeTempBitmap(dupe);
            maskMap.remove(shape);
        }
    }

    public function localToLayer(x:Float = 0.0, y:Float = 0.0, temp = 0):Point {
        throw 'Not implemented';
    }

    public function layerToLocal(x:Float, y:Float, temp = 0):Point {
        throw 'Not implemented';
    }

    public inline function rectToLayer(rect:Rectangle) {
        var top = localToLayer(rect.x, rect.y, 1);
        var bottom = localToLayer(rect.x + rect.width, rect.y + rect.height, 2);
        return new Rectangle(top.x, top.y, bottom.x - top.x, bottom.y - top.y);
    }

    public inline function exists(name:String, og = false):Bool {
        return _names.exists(name) && (!og || _names.get(name).og);
    }

    public function get(?name:String):FinalSprite {
        return if (_names.exists(name)) {
            _names.get(name);
        } else if (_texts.exists(name)) {
            _texts.get(name);
        } else {
            if (_definition != null) Log.warn('Child: $name does not exists! ${_name} ${layer.path}');
            var sprite = FinalSprite.create(layer);

            sprite._name = name;
            _names.set(name, sprite);
            
            addSprite(sprite);
            
            sprite;
        }
    }

    public function getText(name:String):FinalText {
        return if (_texts.exists(name)) {
            _texts.get(name);
        } else {
            if (_definition != null) Log.warn('Text: $name does not exists! ${_name} ${layer.path}');
            var text = FinalText.create(layer);

            text._name = name;
            _texts.set(name, text);

            addSprite(text, false);
            
            text;
        }
    }

    public function dispose() {
        // TODO: Not really necessary... I guess it can help a bit the GC...
        if (!disposed) {
            if (!updating) {
                disposed = true;

                removeFromParent();
                _parent = null;

                for (sprite in _sprites) {
                    sprite._parent = null;
                    sprite.dispose();
                }

                if (isMasked) {
                    isMasked = false;
                    layer.removePostPostRender(calculateMask);
                }

                /*for (shape in maskMap) {
                    layer.disposeTempBitmap(shape);
                }

                maskMap = new Map();
                _sprites = [];
                _bitmaps = [];*/

                removeAll(); // Same as commented above
                
                // TODO: Should I null everything?
                _renders = [];
                _rendersMap = new StringMap();

                _names = new StringMap();
                _texts = new StringMap();

                _added = [];
                _removed = [];

                _pruneAdded = [];
                _pruneRemoved = [];
                _pruneRenders = [];
                _pruneSprites = [];

                _bounds = null;
            } else {
                canDispose = true;
            }
        }
    }
}