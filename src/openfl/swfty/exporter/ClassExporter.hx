package openfl.swfty.exporter;

import haxe.ds.StringMap;

import swfty.utils.Macro;

using Lambda;

typedef ChildTemplate = {
    @:optional var text:Bool;
    @:optional var sprite:Bool;

    var name:String;
    var abstractName:String;
}

typedef DefinitionTemplate = {
    var definition:String;
    var name:String;
    var children:Array<ChildTemplate>;
}

typedef LayerTemplate = {
    var name:String;
    var capitalizedName:String;
    var path:String;
    @:optional var resPath:String;

    var definitions:Array<DefinitionTemplate>;
}

typedef QualityTemplate = {
    var path:String;
    var name:String;
    var capitalizedName:String;
}

typedef FileTemplate = {
    var path:String;
    var name:String;
    var capitalizedName:String;
}

typedef SWFTYTemplate = {
    var qualities:Array<QualityTemplate>;
    var files:Array<FileTemplate>;
}

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

    // Export root abstract
    public static function exportRoot(?quality:StringMap<String>, ?files:Array<FileTemplate>, template:String = '') {
        if (quality == null) quality = ['normal' => ''];
        if (files == null) files = [];

        var qualities:Array<QualityTemplate> = [];
        for (key in quality.keys()) {
            var path = quality.get(key).replace('\\', '/');
            qualities.push({
                name: key,
                capitalizedName: key.capitalize(),
                path: path
            });
        }

        // Mustache template
        var context:SWFTYTemplate = {
            qualities: qualities,
            files: files
        };

        var defaultTemplate = Macro.readTemplate('SWFTY.hx');
        return Mustache.render(template.empty() ? defaultTemplate : template, context);
    }

    // Export to a String
    public static function export(swfty:SWFTYType, name:String, path:String = '', resPath:String = '', template:String = '') {
        var capitalizedName = name.capitalize();

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
        var definitions:Array<DefinitionTemplate> = [];
        for (definition in abstractNames.keys()) {
            var name = abstractNames.get(definition);

            var children:Array<ChildTemplate> = [];
            for (child in definition.children) {
                if (!child.name.empty()) {
                    if (child.text != null) {
                        children.push({
                            name: child.name,
                            text: true,
                            abstractName: 'Text'
                        });
                    } else if (child.mc != null) {
                        var abstractName = abstractNames.exists(child.mc) ? (capitalizedName + '_' + abstractNames.get(child.mc)) : 'Sprite';
                        children.push({
                            name: child.name,
                            sprite: true,
                            abstractName: abstractName
                        });
                    }
                }
            }

            definitions.push({
                definition: definition.name.empty() ? null : definition.name,
                name: name,
                children: children
            });
        }

        // Mustache template
        var context:LayerTemplate = {
            path: path,
            resPath: resPath, 
            name: name,
            capitalizedName: capitalizedName,

            definitions: definitions
        };

        var defaultTemplate = Macro.readTemplate('Layer.hx');
        return Mustache.render(template.empty() ? defaultTemplate : template, context);
    }
}