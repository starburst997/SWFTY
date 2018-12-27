package swfty.utils;

class Tools {

    public static inline function empty(str:String):Bool {
        return str == null || str == '';
    }

    public static inline function capitalize(str:String):String {
        return str == null || str == '' ? '' : str.charAt(0).toUpperCase() + str.substr(1);
    }

    @:generic
    public static inline function sortf<T>(array:Array<T>, f:T->Float) {
        haxe.ds.ArraySort.sort(array, function(a, b):Int {
            var va = f(a);
            var vb = f(b);
            if (va < vb) return -1;
            else if (va > vb) return 1;
            return 0;
        });
        return array;
    }

    @:generic
    public static inline function sortdf<T>(array:Array<T>, f:T->Float) {
        haxe.ds.ArraySort.sort(array, function(a, b):Int {
            var va = f(a);
            var vb = f(b);
            if (va < vb) return 1;
            else if (va > vb) return -1;
            return 0;
        });
        return array;
    }
}