package openfl.swfty.exporter;

import hx.files.*;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.io.Bytes;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

using Lambda;

/**
 * Goal isn't performance but rather type safety, we want the code to fail to compile if a sprite or textfield is missing
 * 
 * I was contemplating having everything saved in the class but this would remove the ability to load SWFTY on the fly
 * The binary format should be fast enough
 * 
 * I was also contemplating using a macro, but I don't want things to get slow, this seemed like the cheapest easiest one
 * since I'll have the swfty CLI running in background constantly watching for file changes
 */
class ClassExporter {

    macro
    public static function readString(filePath:String):ExprOf<String> {
        var posInfos = Context.getPosInfos(Context.currentPos());
        var directory = Path.directory(posInfos.file);
        var file = File.of(Context.resolvePath(Dir.of('$directory/../../../templates/$filePath').toString()));
        var content = file.readAsString();
        return toExpr(content);
    }

    // Export root abstract
    public static function exportRoot(?quality:StringMap<String>) {
        #if (filesystem_support || macro)
        if (quality == null) quality = ['normal' => ''];

        var qualities = '';
        for (key in quality.keys()) {
            var path = quality.get(key).replace('\\', '/');
            qualities += '    var ${key.capitalize()} = "${path}";\n';
        }

        // Read all the files in 
        var layers = '';
        for (file in Dir.of(quality.get('normal')).findFiles("**/*.swfty")) {
            trace(file);
        }
        

        var q = '
@:enum
abstract Quality(String) from String to String {
$qualities
}';

        var l = '
@:enum
abstract Quality(String) from String to String {
$layers
}';

        var file = 'package swfty;

/** This file is auto-generated! **/
$q

$l

class SWFTY {

}';

        return file;
        #else
        return '';
        #end
    }

    // Export to a String
    public static function export(swfty:SWFTYType, name:String, path:String = '', resPath:String = '') {
        var capitalizedName = name.capitalize();

        var defaultTemplate = readString('Layer.hx.mustache');

        // First get the top leveled named MovieClip, the rest are innacessible 
        // but we will create definition for any named children with a dummy class name
        var n = 0;
        var abstractNames:Map<MovieClipType, String> = new Map();
        var dupeNames:StringMap<Int> = new StringMap();
        
        var addDefinition = function f(definition:MovieClipType, allow = false) {
            if (abstractNames.exists(definition) || 
                (!allow && (definition.children.count(function(child) return !child.name.empty() && (child.mc != null || child.text != null)) == 0))) 
                return;
            
            var name = definition.name.empty() ? 'Instance${n++}' : definition.name.capitalize().replace('.', '_');
            //if (name == capitalizedName) name += '_';

            // Make sure there is no dupe
            var dupe = 0;
            if (dupeNames.exists(name)) {
                dupe = dupeNames.get(name) + 1;
            }
            dupeNames.set(name, dupe);

            for (i in 0...dupe) name += '_';
            abstractNames.set(definition, name);
            
            // Each of it's named children should be included as well
            for (child in definition.children) {
                if (!child.name.empty() && (child.mc != null)) {
                    f(child.mc);
                }
            }
        }
        
        for (definition in swfty.definitions) {
            if (!definition.name.empty()) {
                addDefinition(definition, true);
            }
        }

        // Once we have all type that we want to include, build them up!
        var getLayerFile = '';
        var abstractsFile = '';
        for (definition in abstractNames.keys()) {
            var name = abstractNames.get(definition);

            var childsFile = '';
            for (child in definition.children) {
                if (!child.name.empty()) {
                    if (child.text != null) {
                        childsFile += '
    public var ${child.name}(get, never):Text;
    public inline function get_${child.name}():Text {
        return this.getText("${child.name}");
    }
                        ';
                    } else if (child.mc != null) {
                         var abstractName = abstractNames.exists(child.mc) ? (capitalizedName + '_' + abstractNames.get(child.mc)) : 'Sprite';

                        childsFile += '
    public var ${child.name}(get, never):$abstractName;
    public inline function get_${child.name}():$abstractName {
        return this.get("${child.name}");
    }
                        ';
                    }
                }
            }

            if (!definition.name.empty()) getLayerFile += '
    public inline function create$name():${capitalizedName}_${name} {
        return this.create("${definition.name}");
    }
            ';

            if (definition.name.empty()) {
                abstractsFile += '
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract ${capitalizedName}_${name}(Sprite) from Sprite to Sprite {
    $childsFile
}
                ';
            } else {
                abstractsFile += '
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract ${capitalizedName}_${name}(Sprite) from Sprite to Sprite {
    $childsFile
    public static inline function create(layer:$capitalizedName):${capitalizedName}_${name} {
        return layer.create$name();
    }
}
                ';
            }
        }

        var layer = '
@:forward(x, y, scaleX, scaleY, rotation, alpha, dispose, pause, layout, mouse, base, baseLayout, width, height, getAllNames, update, create, add, remove, addRender, removeRender, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouseX, mouseY)
abstract $capitalizedName(Layer) from Layer to Layer {
    $getLayerFile
    public inline function reload(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete() {
            this.reload();
            if (onComplete != null) onComplete();
        }

        if (bytes != null) {
            this.loadBytes(bytes, complete, onError);
        } else {
            _load(this.path, complete, onError);
        }
    }

    inline function _load(?path:String = "", ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        this.path = path;
        File.loadBytes(path, function(bytes) {
            this.loadBytes(bytes, onComplete, onError);
        }, onError);
    }

    inline function _loadBytes(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        this.loadBytes(bytes, onComplete, onError);
    }

    public static inline function getPath(?quality:Quality) {
        if (quality == null) quality = Normal;
        return "$resPath" + quality + "$name.swfty";
    }

    public static inline function load(?quality:Quality, ?width:Int, ?height:Int, ?bytes:Bytes, ?onComplete:$capitalizedName->Void, ?onError:Dynamic->Void):$capitalizedName {
        var layer:$capitalizedName = Layer.empty(width, height);
        if (bytes != null) {
            layer._loadBytes(bytes, function() if (onComplete != null) onComplete(layer), onError);
        } else {
            layer._load(getPath(quality), function() if (onComplete != null) onComplete(layer), onError);
        }
        return layer;
    }

    public static inline function create(?width:Int, ?height:Int):$capitalizedName {
        return Layer.empty(width, height);
    }
}';

        var file = 'package swfty$path;

import haxe.io.Bytes;

import swfty.SWFTY;
import swfty.utils.File;
import swfty.renderer.Sprite;
import swfty.renderer.Text;
import swfty.renderer.Layer;

/** This file is auto-generated! **/
$layer
$abstractsFile';

        return file;
    }
}