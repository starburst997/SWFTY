package swfty.utils;

class Tools {

    public static inline function empty(str:String):Bool {
        return str == null || str == '';
    }

    public static inline function capitalize(str:String):String {
        return str == null || str == '' ? '' : str.charAt(0).toUpperCase() + str.substr(1);
    }
}