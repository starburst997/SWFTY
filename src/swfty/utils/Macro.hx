package swfty.utils;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
#end

class Macro {
    
    macro
    public static function readTemplate(name:String):ExprOf<String> {
        var posInfos = Context.getPosInfos(Context.currentPos());
        var directory = Path.directory(posInfos.file);
        var content = File.getContent('$directory/../../../../templates/$name.mustache');
        return macro $v{content};
    }
}