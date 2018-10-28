package heaps.swfty.utils;

import haxe.io.Bytes;

class File {

    public static function loadBytes(path:String, onComplete:Bytes->Void, ?onError:Dynamic->Void) {
        #if js
        // TODO: Is this a potential memory leak?
        var loader = new hxd.net.BinaryLoader('res/$path');
        loader.onLoaded = (bytes) -> {
            trace('Complete loadBytes ${bytes.length}');
            onComplete(bytes);
        };
        loader.onError = (e) -> {
            trace('Error loadBytes', e);
            if (onError != null) onError(e);
        }
        loader.load();
        #else
        var file = hxd.Res.load(path);
        var bytes = file.entry.getBytes();

        if (bytes != null) {
            trace('Complete loadBytes ${bytes.length}');
            onComplete(bytes);
        } else {
            var e = 'No file found';
            trace('Error loadBytes', e);
            if (onError != null) onError(e);
        }
        #end
    }
}