package openfl.swfty.exporter;

import haxe.ds.IntMap;

import openfl.swfty.exporter.Shape;
import openfl.swfty.exporter.MovieClip;
import openfl.swfty.exporter.FontExporter;
import openfl.swfty.exporter.TilemapExporter;

/**
 * Goal isn't performance but rather type safety, we want the code to fail to compile if a sprite or textfield is missing
 * 
 * This could be just Abstract
 * 
 * I was contemplating having everything saved in the class but this would remove the ability to load SWFTY on the fly
 * The binary format should be fast enough
 */
class ClassExporter {

    // Export to a String
    public static function export(swfty:SWFTYType, name:String) {


    }

    // Save on filesystem
    public static function exportPath(path:String, swfty:SWFTYType, name:String) {

    }
}

/*var popup = Popup.create(layer);
layer.addChild(popup);*/

@:forward(x, y, scaleX, scaleY, rotation, getTile, get)
abstract MyFLA(Layer) from Layer to Layer {

    public inline function getInstance1():Instance1 {
        return this.get('Instance1');
    }

    public static inline function create(width:Int, height:Int, ?onComplete:MyFLA->Void, ?onError:Dynamic->Void):MyFLA {
        var layer = Layer.create(width, height);
        File.loadBytes('tower.swfty', bytes -> {
            layer.load(bytes, () -> {
                if (onComplete != null) onComplete(layer);
            }, (e) -> {
                if (onError != null) onError(e);
            });
        }, (e) -> {
            if (onError != null) onError(e);
        });
        return layer;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, addTile)
abstract Instance1(Sprite) from Sprite to Sprite {

    public var name1(get, never):Instance1;

    public inline function get_name1() {
        return this.get('name1');
    }

    // Only have create on named MovieClip (linkage name)
    public static inline function create(layer:MyFLA):Instance1 {
        return layer.getInstance1();
    }
}