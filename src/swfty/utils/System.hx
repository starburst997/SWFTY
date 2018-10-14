package swfty.utils;

class System {

    public static inline var project = 'SWFTY';

    public static inline function getPath(path:String = '') {
        #if sys
        // TODO: Other platforms
        return Sys.getCwd().replace('$project.app/Contents/Resources/', '').replace('bin/macos/bin/', '') + path;
        #else 
        return path;
        #end
    }
}