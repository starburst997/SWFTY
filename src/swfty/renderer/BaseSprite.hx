package swfty.renderer;

import haxe.ds.StringMap;

@:allow(swfty.renderer.BaseSprite)
class BaseSprite extends EngineSprite {

    static var COUNTER = 0;

    var disposed = false;

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
    var _names:StringMap<FinalSprite>;
    var _texts:StringMap<FinalText>;
    var _definition:Null<MovieClipType>;
    var _bounds:Rectangle;

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

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        super();

        this.layer = layer;
        this._layer = layer;
        _linkage = linkage;

        _added = [];
        _removed = [];

        _renders = [];
        _rendersMap = new StringMap();

        _sprites = [];
        _names = new StringMap();
        _texts = new StringMap();

        _pruneAdded = [];
        _pruneRemoved = [];
        _pruneRenders = [];
        _pruneSprites = [];

        load(definition);
    }

    function set__name(name:String) {
        if (_parent != null) {
            _parent._names.remove(_name);
        }
        
        _name = name;
        return _name;
    }

    // TODO: Not super optimized, usually getting the X we would also get the Y so we could cache it for one frame
    public inline function getMouseX():Float {
        return layerToLocal(layer.mouse.x, layer.mouse.y).x;
    }

    public inline function getMouseY():Float {
        return layerToLocal(layer.mouse.x, layer.mouse.y).y;
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

    public function update(dt:Float) {
        // TODO: Wonder if that's the best solution... If it's invisible I wouldn't want anything called...
        //       Maybe sleep() / awake() sprite?
        //if (!_visible) return;

        if (countVisible) _layer.hasVisible = true;

        for (sprite in _sprites) {
            sprite.update(dt);
        }

        if (loaded) for (f in _renders) f(dt);

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
    }

    public inline function display():DisplaySprite {
        return this;
    }

    // This is a "soft" clear, it won't call any event
    function removeAll() {
        display().removeAll();
        _sprites = [];
    }

    public function load(definition:MovieClipType) {
        _definition = definition;
        if (definition != null) _linkage = definition.name;
        
        var childs = _sprites;
        var skipChilds = [];

        // Clear all childrens
        removeAll();

        if (definition == null) return;

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
                var text = if (!child.name.empty() && _texts.exists(child.name)) {
                    var text = _texts.get(child.name);

                    if (!loaded) {
                        if (!text._visible) updateVisible = false;
                        if (text.x != 0 || text.y != 0) updatePosition = false;
                        if (text.scaleX != 1 || text.scaleY != 1) updateScale = false;
                        if (text.rotation != 0) updateRotation = false;
                        if (text.alpha != 1) updateAlpha = false;
                    }

                    text.loadText(child.text);

                    text.refresh();
                    for (sprite in text._sprites) {
                        sprite.refresh();
                    }

                    text;
                } else {
                    var text = FinalText.create(layer, child.text);

                    if (!child.name.empty()) {
                        text._name = child.name;
                        _texts.set(child.name, text);
                    }
                    text;
                }

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
                    textSprite.dispose();
                }
                
                text.og = true;
                text.loaded = true;

                if (updatePosition && updateScale && updateRotation) text.display().transform(child.a, child.b, child.c, child.d, child.tx + child.text.x, child.ty + child.text.y);
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
                    tile.transform(shape.a, shape.b, shape.c, shape.d, shape.tx, shape.ty);
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
        if (sprite._name != null) _names.set(sprite._name, sprite);
        _sprites.insert(index, sprite);
        
        // TODO: Was that necessary?
        if (!sprite.loaded && sprite.layer.loaded) {
            sprite.reload();
        }
    }

    public function addSprite(sprite:FinalSprite) {
        if (sprite._name != null) _names.set(sprite._name, sprite);
        _sprites.push(sprite);
        
        // TODO: Was that necessary?
        if (!sprite.loaded && sprite.layer.loaded) {
            sprite.reload();
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
        throw 'Not implemented';
    }

    public function removeBitmap(shape:EngineBitmap) {
        throw 'Not implemented';
    }

    public function localToLayer(x:Float = 0.0, y:Float = 0.0):Point {
        throw 'Not implemented';
    }

    public function layerToLocal(x:Float, y:Float):Point {
        throw 'Not implemented';
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
            addSprite(text);
            text;
        }
    }

    public function dispose() {
        // TODO: Not really necessary... I guess it can help a bit the GC...
        if (!disposed) {
            disposed = true;

            removeFromParent();
            _parent = null;

            for (sprite in _sprites) {
                sprite._parent = null;
                sprite.dispose();
            }
            
            // TODO: Should I null everything?
            _renders = [];
            _rendersMap = new StringMap();

            _sprites = [];
            _names = new StringMap();
            _texts = new StringMap();

            _added = [];
            _removed = [];

            _pruneAdded = [];
            _pruneRemoved = [];
            _pruneRenders = [];
            _pruneSprites = [];

            _bounds = null;
        }
    }
}