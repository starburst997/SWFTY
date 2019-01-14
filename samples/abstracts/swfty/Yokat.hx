package swfty;

import haxe.io.Bytes;

import swfty.SWFTY;
import swfty.utils.File;
import swfty.renderer.Sprite;
import swfty.renderer.Text;
import swfty.renderer.Layer;

/** This file is auto-generated! **/

@:forward(x, y, scaleX, scaleY, rotation, alpha, dispose, pause, layout, mouse, base, baseLayout, width, height, getAllNames, update, create, add, remove, addRender, removeRender, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouseX, mouseY)
abstract Yokat(Layer) from Layer to Layer {
    
    public inline function createCatHeadAGlow():Yokat_CatHeadAGlow {
        return this.create("CatHeadAGlow");
    }
            
    public inline function createCatHeadBGlow():Yokat_CatHeadBGlow {
        return this.create("CatHeadBGlow");
    }
            
    public inline function createCatHeadCOver():Yokat_CatHeadCOver {
        return this.create("CatHeadCOver");
    }
            
    public inline function createCatHeadAOver():Yokat_CatHeadAOver {
        return this.create("CatHeadAOver");
    }
            
    public inline function createCatHeadDOver():Yokat_CatHeadDOver {
        return this.create("CatHeadDOver");
    }
            
    public inline function createCatHeadEOver():Yokat_CatHeadEOver {
        return this.create("CatHeadEOver");
    }
            
    public inline function createCatHeadE():Yokat_CatHeadE {
        return this.create("CatHeadE");
    }
            
    public inline function createFix():Yokat_Fix {
        return this.create("Fix");
    }
            
    public inline function createCatHeadCGlow():Yokat_CatHeadCGlow {
        return this.create("CatHeadCGlow");
    }
            
    public inline function createUI():Yokat_UI {
        return this.create("UI");
    }
            
    public inline function createLineCounter():Yokat_LineCounter {
        return this.create("LineCounter");
    }
            
    public inline function createPointsIcon():Yokat_PointsIcon {
        return this.create("PointsIcon");
    }
            
    public inline function createCatHeadBOver():Yokat_CatHeadBOver {
        return this.create("CatHeadBOver");
    }
            
    public inline function createCatHeadD():Yokat_CatHeadD {
        return this.create("CatHeadD");
    }
            
    public inline function createCatHeadC():Yokat_CatHeadC {
        return this.create("CatHeadC");
    }
            
    public inline function createLine():Yokat_Line {
        return this.create("Line");
    }
            
    public inline function createCatHeadB():Yokat_CatHeadB {
        return this.create("CatHeadB");
    }
            
    public inline function createCatHeadDGlow():Yokat_CatHeadDGlow {
        return this.create("CatHeadDGlow");
    }
            
    public inline function createCatHeadEGlow():Yokat_CatHeadEGlow {
        return this.create("CatHeadEGlow");
    }
            
    public inline function createCatHeadA():Yokat_CatHeadA {
        return this.create("CatHeadA");
    }
            
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
        File.loadBytes("" + path + "Yokat.swfty", function(bytes) {
            this.loadBytes(bytes, onComplete, onError);
        }, onError);
    }


    inline function _loadBytes(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        this.loadBytes(bytes, onComplete, onError);
    }

    public static inline function load(?quality:Quality, ?width:Int, ?height:Int, ?bytes:Bytes, ?onComplete:Yokat->Void, ?onError:Dynamic->Void):Yokat {
        if (quality == null) quality = Normal;
        var layer:Yokat = Layer.empty(width, height);
        if (bytes != null) {
            layer._loadBytes(bytes, function() if (onComplete != null) onComplete(layer), onError);
        } else {
            layer._load(quality, function() if (onComplete != null) onComplete(layer), onError);
        }
        return layer;
    }

    public static inline function create(?width:Int, ?height:Int):Yokat {
        return Layer.empty(width, height);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadAGlow(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadAGlow {
        return layer.createCatHeadAGlow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadBGlow(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadBGlow {
        return layer.createCatHeadBGlow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadCOver(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadCOver {
        return layer.createCatHeadCOver();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadAOver(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadAOver {
        return layer.createCatHeadAOver();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadDOver(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadDOver {
        return layer.createCatHeadDOver();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadEOver(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadEOver {
        return layer.createCatHeadEOver();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadE(Sprite) from Sprite to Sprite {
    
    public var head(get, never):Sprite;
    public inline function get_head():Sprite {
        return this.get("head");
    }
                        
    public var selected(get, never):Yokat_CatHeadEGlow;
    public inline function get_selected():Yokat_CatHeadEGlow {
        return this.get("selected");
    }
                        
    public var over(get, never):Yokat_CatHeadEOver;
    public inline function get_over():Yokat_CatHeadEOver {
        return this.get("over");
    }
                        
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadE {
        return layer.createCatHeadE();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance11(Sprite) from Sprite to Sprite {
    
    public var materials(get, never):Sprite;
    public inline function get_materials():Sprite {
        return this.get("materials");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Fix(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Yokat):Yokat_Fix {
        return layer.createFix();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance8(Sprite) from Sprite to Sprite {
    
    public var boostAmount(get, never):Text;
    public inline function get_boostAmount():Text {
        return this.getText("boostAmount");
    }
                        
    public var hearts(get, never):Yokat_Instance9;
    public inline function get_hearts():Yokat_Instance9 {
        return this.get("hearts");
    }
                        
    public var crafting(get, never):Yokat_Instance10;
    public inline function get_crafting():Yokat_Instance10 {
        return this.get("crafting");
    }
                        
    public var materials(get, never):Yokat_Instance11;
    public inline function get_materials():Yokat_Instance11 {
        return this.get("materials");
    }
                        
    public var minigame(get, never):Yokat_Instance12;
    public inline function get_minigame():Yokat_Instance12 {
        return this.get("minigame");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadCGlow(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadCGlow {
        return layer.createCatHeadCGlow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance1(Sprite) from Sprite to Sprite {
    
    public var boxRight(get, never):Sprite;
    public inline function get_boxRight():Sprite {
        return this.get("boxRight");
    }
                        
    public var boxRight_(get, never):Sprite;
    public inline function get_boxRight_():Sprite {
        return this.get("boxRight_");
    }
                        
    public var button(get, never):Sprite;
    public inline function get_button():Sprite {
        return this.get("button");
    }
                        
    public var label(get, never):Text;
    public inline function get_label():Text {
        return this.getText("label");
    }
                        
    public var score(get, never):Yokat_Instance2;
    public inline function get_score():Yokat_Instance2 {
        return this.get("score");
    }
                        
    public var rank(get, never):Yokat_Instance2;
    public inline function get_rank():Yokat_Instance2 {
        return this.get("rank");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance3(Sprite) from Sprite to Sprite {
    
    public var boxRight(get, never):Sprite;
    public inline function get_boxRight():Sprite {
        return this.get("boxRight");
    }
                        
    public var label(get, never):Text;
    public inline function get_label():Text {
        return this.getText("label");
    }
                        
    public var score(get, never):Yokat_Instance4;
    public inline function get_score():Yokat_Instance4 {
        return this.get("score");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance10(Sprite) from Sprite to Sprite {
    
    public var crafting(get, never):Sprite;
    public inline function get_crafting():Sprite {
        return this.get("crafting");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance6(Sprite) from Sprite to Sprite {
    
    public var guildMessage(get, never):Yokat_Instance7;
    public inline function get_guildMessage():Yokat_Instance7 {
        return this.get("guildMessage");
    }
                        
    public var boostButton(get, never):Yokat_Instance8;
    public inline function get_boostButton():Yokat_Instance8 {
        return this.get("boostButton");
    }
                        
    public var closeButton(get, never):Sprite;
    public inline function get_closeButton():Sprite {
        return this.get("closeButton");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance2(Sprite) from Sprite to Sprite {
    
    public var label(get, never):Text;
    public inline function get_label():Text {
        return this.getText("label");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_UI(Sprite) from Sprite to Sprite {
    
    public var game(get, never):Sprite;
    public inline function get_game():Sprite {
        return this.get("game");
    }
                        
    public var lines(get, never):Sprite;
    public inline function get_lines():Sprite {
        return this.get("lines");
    }
                        
    public var meter(get, never):Yokat_Instance0;
    public inline function get_meter():Yokat_Instance0 {
        return this.get("meter");
    }
                        
    public var highscore(get, never):Yokat_Instance1;
    public inline function get_highscore():Yokat_Instance1 {
        return this.get("highscore");
    }
                        
    public var score(get, never):Yokat_Instance3;
    public inline function get_score():Yokat_Instance3 {
        return this.get("score");
    }
                        
    public var banner(get, never):Yokat_Instance5;
    public inline function get_banner():Yokat_Instance5 {
        return this.get("banner");
    }
                        
    public var bottom(get, never):Yokat_Instance6;
    public inline function get_bottom():Yokat_Instance6 {
        return this.get("bottom");
    }
                        
    public var fx(get, never):Sprite;
    public inline function get_fx():Sprite {
        return this.get("fx");
    }
                        
    public var info(get, never):Sprite;
    public inline function get_info():Sprite {
        return this.get("info");
    }
                        
    public var pause(get, never):Sprite;
    public inline function get_pause():Sprite {
        return this.get("pause");
    }
                        
    public static inline function create(layer:Yokat):Yokat_UI {
        return layer.createUI();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance5(Sprite) from Sprite to Sprite {
    
    public var banner(get, never):Sprite;
    public inline function get_banner():Sprite {
        return this.get("banner");
    }
                        
    public var label(get, never):Text;
    public inline function get_label():Text {
        return this.getText("label");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance4(Sprite) from Sprite to Sprite {
    
    public var label(get, never):Text;
    public inline function get_label():Text {
        return this.getText("label");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance14(Sprite) from Sprite to Sprite {
    
    public var shape(get, never):Sprite;
    public inline function get_shape():Sprite {
        return this.get("shape");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance7(Sprite) from Sprite to Sprite {
    
    public var message(get, never):Text;
    public inline function get_message():Text {
        return this.getText("message");
    }
                        
    public var unmuted(get, never):Sprite;
    public inline function get_unmuted():Sprite {
        return this.get("unmuted");
    }
                        
    public var muted(get, never):Sprite;
    public inline function get_muted():Sprite {
        return this.get("muted");
    }
                        
    public var muteButton(get, never):Sprite;
    public inline function get_muteButton():Sprite {
        return this.get("muteButton");
    }
                        
    public var click(get, never):Sprite;
    public inline function get_click():Sprite {
        return this.get("click");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_LineCounter(Sprite) from Sprite to Sprite {
    
    public var container(get, never):Yokat_Instance13;
    public inline function get_container():Yokat_Instance13 {
        return this.get("container");
    }
                        
    public static inline function create(layer:Yokat):Yokat_LineCounter {
        return layer.createLineCounter();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_PointsIcon(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Yokat):Yokat_PointsIcon {
        return layer.createPointsIcon();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadBOver(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadBOver {
        return layer.createCatHeadBOver();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadD(Sprite) from Sprite to Sprite {
    
    public var head(get, never):Sprite;
    public inline function get_head():Sprite {
        return this.get("head");
    }
                        
    public var selected(get, never):Yokat_CatHeadDGlow;
    public inline function get_selected():Yokat_CatHeadDGlow {
        return this.get("selected");
    }
                        
    public var over(get, never):Yokat_CatHeadDOver;
    public inline function get_over():Yokat_CatHeadDOver {
        return this.get("over");
    }
                        
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadD {
        return layer.createCatHeadD();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadC(Sprite) from Sprite to Sprite {
    
    public var head(get, never):Sprite;
    public inline function get_head():Sprite {
        return this.get("head");
    }
                        
    public var selected(get, never):Yokat_CatHeadCGlow;
    public inline function get_selected():Yokat_CatHeadCGlow {
        return this.get("selected");
    }
                        
    public var over(get, never):Yokat_CatHeadCOver;
    public inline function get_over():Yokat_CatHeadCOver {
        return this.get("over");
    }
                        
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadC {
        return layer.createCatHeadC();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Line(Sprite) from Sprite to Sprite {
    
    public var shape(get, never):Sprite;
    public inline function get_shape():Sprite {
        return this.get("shape");
    }
                        
    public var line(get, never):Yokat_Instance14;
    public inline function get_line():Yokat_Instance14 {
        return this.get("line");
    }
                        
    public var fix(get, never):Yokat_Fix;
    public inline function get_fix():Yokat_Fix {
        return this.get("fix");
    }
                        
    public static inline function create(layer:Yokat):Yokat_Line {
        return layer.createLine();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance0(Sprite) from Sprite to Sprite {
    
    public var bar(get, never):Sprite;
    public inline function get_bar():Sprite {
        return this.get("bar");
    }
                        
    public var barMC(get, never):Sprite;
    public inline function get_barMC():Sprite {
        return this.get("barMC");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadB(Sprite) from Sprite to Sprite {
    
    public var head(get, never):Sprite;
    public inline function get_head():Sprite {
        return this.get("head");
    }
                        
    public var selected(get, never):Yokat_CatHeadBGlow;
    public inline function get_selected():Yokat_CatHeadBGlow {
        return this.get("selected");
    }
                        
    public var over(get, never):Yokat_CatHeadBOver;
    public inline function get_over():Yokat_CatHeadBOver {
        return this.get("over");
    }
                        
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadB {
        return layer.createCatHeadB();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance13(Sprite) from Sprite to Sprite {
    
    public var scoreText(get, never):Text;
    public inline function get_scoreText():Text {
        return this.getText("scoreText");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance9(Sprite) from Sprite to Sprite {
    
    public var hearts(get, never):Sprite;
    public inline function get_hearts():Sprite {
        return this.get("hearts");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadDGlow(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadDGlow {
        return layer.createCatHeadDGlow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadEGlow(Sprite) from Sprite to Sprite {
    
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadEGlow {
        return layer.createCatHeadEGlow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_Instance12(Sprite) from Sprite to Sprite {
    
    public var minigame(get, never):Sprite;
    public inline function get_minigame():Sprite {
        return this.get("minigame");
    }
                        
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Yokat_CatHeadA(Sprite) from Sprite to Sprite {
    
    public var head(get, never):Sprite;
    public inline function get_head():Sprite {
        return this.get("head");
    }
                        
    public var selected(get, never):Yokat_CatHeadAGlow;
    public inline function get_selected():Yokat_CatHeadAGlow {
        return this.get("selected");
    }
                        
    public var over(get, never):Yokat_CatHeadAOver;
    public inline function get_over():Yokat_CatHeadAOver {
        return this.get("over");
    }
                        
    public var collision(get, never):Sprite;
    public inline function get_collision():Sprite {
        return this.get("collision");
    }
                        
    public static inline function create(layer:Yokat):Yokat_CatHeadA {
        return layer.createCatHeadA();
    }
}
                