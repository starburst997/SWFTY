package swfty.renderer;

import haxe.ds.StringMap;

class BaseSprite extends EngineSprite {

    public var og:Bool = false;

    public var layer:BaseLayer;

    // TODO: Only used on heaps, kind of a hack, I think saving the ColorType instead might solve this
    public var r:Float = 1.0;
    public var g:Float = 1.0;
    public var b:Float = 1.0;

    // For reload if definition didn't exists
    var _linkage:String;

    // Using underscore to prevent var clasing with base class
    // TODO: All private var should have an underscore?
    var _name:String;
    var _parent:FinalSprite;
    var _sprites:Array<FinalSprite>;
    var _names:StringMap<FinalSprite>;
    var _texts:StringMap<FinalText>;
    var _definition:Null<MovieClipType>;

    // Being able to add a render loop is a pretty nice tool
    // The map allows you to give it a name so you can easily remove all render loop from a specific name 
    var _renders:Array<Float->Void>;
    var _rendersMap:StringMap<Array<Float->Void>>;

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        super();

        this.layer = layer;
        _linkage = linkage;
        
        _renders = [];
        _rendersMap = new StringMap();

        _sprites = [];
        _names = new StringMap();
        _texts = new StringMap();
    
        load(definition);
    }

    public inline function addRender(?name:String, f:Float->Void) {
        _renders.push(f);
        if (name != null) {
            if (!_rendersMap.exists(name)) _rendersMap.set(name, []);
            _rendersMap.get(name).push(f);
        }
    }

    public inline function removeRender(?name:String, ?f:Float->Void) {
        if (f != null) {
            _renders.remove(f);

            if (_rendersMap.exists(name)) {
                _rendersMap.get(name).remove(f);
            }
        } else if (name != null && _rendersMap.exists(name)) {
            for (f in _rendersMap.get(name)) {
                _renders.remove(f);
            }
            
            _rendersMap.remove(name);
        }
    }

    public function update(dt:Float) {
        for (sprite in _sprites) {
            sprite.update(dt);
        }

        for (f in _renders) f(dt);
    }

    public inline function display():DisplaySprite {
        return this;
    }

    public function removeAll() {
        display().removeAll();
        _sprites = [];
    }

    public function load(definition:MovieClipType) {
        _definition = definition;
        
        var childs = _sprites;

        // Clear all childrens
        removeAll();

        if (definition == null) return;

        // Create children
        for (child in definition.children) {
            if (child.text != null) {
                var text = if (!child.name.empty() && _texts.exists(child.name)) {
                    var text = _texts.get(child.name);
                    text.loadText(child.text);
                    text;
                } else {
                    var text = FinalText.create(layer, child.text);

                    if (!child.name.empty()) {
                        text._name = child.name;
                        _texts.set(child.name, text);
                    }
                    text;
                }
                
                text.og = true;

                text.display().transform(child.a, child.b, child.c, child.d, child.tx, child.ty);
                text.visible = child.visible;

                addSprite(text);
            } else {
                var sprite = if (!child.name.empty() && _names.exists(child.name)) {
                    var sprite = _names.get(child.name);
                    sprite.load(child.mc);
                    sprite;
                } else {
                    var sprite = FinalSprite.create(layer, child.mc);
                    if (!child.name.empty()) {
                        sprite._name = child.name;
                        _names.set(child.name, sprite);
                    }
                    sprite;
                }

                sprite.og = true;
                
                sprite.display().transform(child.a, child.b, child.c, child.d, child.tx, child.ty);
                sprite.alpha = child.alpha;
                sprite.visible = child.visible;

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

                for (shape in child.shapes) {
                    var tile = layer.createBitmap(shape.bitmap.id, true);
                    tile.transform(shape.a, shape.b, shape.c, shape.d, shape.tx, shape.ty);

                    sprite.addBitmap(tile);
                }

                addSprite(sprite);
            }
        }

        // Re-add non-og tile
        for (child in childs) {
            if (!child.og) {
                if (!child._name.empty()) Log.warn('Missing Child: ${child._name}');

                child.reload();

                // TODO: Usually non-og sprites are added on top, figure out a better way to preserve order
                addSprite(child);
            }
        }
    }

    public inline function getParent() {
        return _parent;
    }

    public function reload() {
        if (_definition != null) {
            if (layer.hasDefinition(_definition.id)) {
                var definition = layer.getDefinition(_definition.id);
                load(definition);
            } else {
                Log.warn('Definition does no longer exists: ${_definition.name} (${_definition.id})');
            }
        } else if (_linkage != null) {
            if (layer.hasMC(_linkage)) {
                var definition = layer.getMC(_linkage);
                load(definition);
            } else {
                Log.warn('Definition does not exists: ${_linkage}');
            }
        }
    }

    public function addSprite(sprite:FinalSprite) {
        _sprites.push(sprite);
    }

    public function removeSprite(sprite:FinalSprite) {
        sprite._parent = null;
        _sprites.remove(sprite);
    }

    public function addBitmap(shape:EngineBitmap) {
        throw 'Not implemented';
    }

    public function removeBitmap(shape:EngineBitmap) {
        throw 'Not implemented';
    }

    public function get(name:String):FinalSprite {
        return if (_names.exists(name)) {
            _names.get(name);
        } else {
            if (_definition != null) Log.warn('Child: $name does not exists!');
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
            if (_definition != null) Log.warn('Text: $name does not exists!');
            var text = FinalText.create(layer);
            text._name = name;
            _texts.set(name, text);
            addSprite(text);
            text;
        }
    }
}