package swfty.utils;

import haxe.io.Bytes;

#if (macro || void)
typedef File = void.swfty.utils.File;
#elseif openfl
typedef File = openfl.swfty.utils.File;
#elseif heaps
typedef File = heaps.swfty.utils.File;
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end

class FileUtils {
    
    public static function exists(path:String) {
        #if sys
        return sys.FileSystem.exists(path);
        #else
        throw 'Not implemented!';
        #end    
    }

    public static function deleteDirectory(path:String) {
        #if sys
        try {
            if (sys.FileSystem.exists(path)) {
                for (file in sys.FileSystem.readDirectory(path)) {
                    if (sys.FileSystem.isDirectory('$path/$file')) {
                        deleteDirectory('$path/$file');
                        sys.FileSystem.deleteDirectory('$path/$file');
                    } else {
                        sys.FileSystem.deleteFile('$path/$file');
                    }
                }
                sys.FileSystem.deleteDirectory('$path');
            }
        } catch(e:Dynamic) {
            
        }
        #else
        throw 'Not implemented!';
        #end    
    }

    public static function createDirectory(path:String, empty = false) {
        #if sys
        if (!sys.FileSystem.exists(path)) {
            sys.FileSystem.createDirectory(path);
        } else if (empty) {
            for (file in sys.FileSystem.readDirectory(path)) {
                if (sys.FileSystem.isDirectory('$path/$file')) {
                    deleteDirectory('$path/$file');
                } else {
                    sys.FileSystem.deleteFile('$path/$file');
                }
            }
        }
        #else
        throw 'Not implemented!';
        #end
    }

    public static function createFile(path:String, bytes:Bytes) {
        #if sys
        if (sys.FileSystem.exists(path)) {
            sys.FileSystem.deleteFile(path);
        }

        sys.io.File.saveBytes(path, bytes);
        #else
        throw 'Not implemented!';
        #end
    }
}