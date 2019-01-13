package swfty;

import haxe.io.Bytes;

import swfty.SWFTY;
import swfty.utils.File;
import swfty.renderer.Sprite;
import swfty.renderer.Text;
import swfty.renderer.Layer;

/** This file is auto-generated! **/

@:forward(x, y, scaleX, scaleY, rotation, alpha, dispose, pause, layout, mouse, base, baseLayout, width, height, getAllNames, update, create, add, remove, addRender, removeRender, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouseX, mouseY)
abstract Popup(Layer) from Layer to Layer {
    
    public inline function createBaloonHighlight():Popup_BaloonHighlight {
        return this.create("BaloonHighlight");
    }
            
    public inline function createShopItems():Popup_ShopItems {
        return this.create("ShopItems");
    }
            
    public inline function createItemShop():Popup_ItemShop {
        return this.create("ItemShop");
    }
            
    public inline function createBalloon_red():Popup_Balloon_red {
        return this.create("balloon_red");
    }
            
    public inline function createPopup_Closebutton():Popup_Popup_Closebutton {
        return this.create("Popup_Closebutton");
    }
            
    public inline function createBalloons():Popup_Balloons {
        return this.create("Balloons");
    }
            
    public inline function createTitleHead():Popup_TitleHead {
        return this.create("TitleHead");
    }
            
    public inline function createMC_ChopperBody():Popup_MC_ChopperBody {
        return this.create("MC_ChopperBody");
    }
            
    public inline function createPopup_fla_headShop_smashRainbow_23():Popup_Popup_fla_headShop_smashRainbow_23 {
        return this.create("Popup_fla.headShop_smashRainbow_23");
    }
            
    public inline function createSold():Popup_Sold {
        return this.create("Sold");
    }
            
    public inline function createBGtitle():Popup_BGtitle {
        return this.create("BGtitle");
    }
            
    public inline function createBaloonShadowInn():Popup_BaloonShadowInn {
        return this.create("BaloonShadowInn");
    }
            
    public inline function createPopup_fla_headShop_smashChopper_26():Popup_Popup_fla_headShop_smashChopper_26 {
        return this.create("Popup_fla.headShop_smashChopper_26");
    }
            
    public inline function createShopDescription():Popup_ShopDescription {
        return this.create("ShopDescription");
    }
            
    public inline function createManNose():Popup_ManNose {
        return this.create("ManNose");
    }
            
    public inline function createBalloon_orange():Popup_Balloon_orange {
        return this.create("balloon_orange");
    }
            
    public inline function createStarMini():Popup_StarMini {
        return this.create("StarMini");
    }
            
    public inline function createFace():Popup_Face {
        return this.create("Face");
    }
            
    public inline function createBtnBack():Popup_BtnBack {
        return this.create("BtnBack");
    }
            
    public inline function createBtnBuy():Popup_BtnBuy {
        return this.create("BtnBuy");
    }
            
    public inline function createIcon_shopItem():Popup_Icon_shopItem {
        return this.create("icon_shopItem");
    }
            
    public inline function createBalloon_blue():Popup_Balloon_blue {
        return this.create("balloon_blue");
    }
            
    public inline function createBalloon_cord_stroke():Popup_Balloon_cord_stroke {
        return this.create("balloon_cord_stroke");
    }
            
    public inline function createBalloon_yellow():Popup_Balloon_yellow {
        return this.create("balloon_yellow");
    }
            
    public inline function createIconOverlay():Popup_IconOverlay {
        return this.create("iconOverlay");
    }
            
    public inline function createBuyLocale():Popup_BuyLocale {
        return this.create("BuyLocale");
    }
            
    public inline function createCurrencyBG():Popup_CurrencyBG {
        return this.create("CurrencyBG");
    }
            
    public inline function createPopupShopMC():Popup_PopupShopMC {
        return this.create("PopupShopMC");
    }
            
    public inline function createShopTitle():Popup_ShopTitle {
        return this.create("ShopTitle");
    }
            
    public inline function createBtnBuyOverlay():Popup_BtnBuyOverlay {
        return this.create("BtnBuyOverlay");
    }
            
    public inline function createBackLocale():Popup_BackLocale {
        return this.create("BackLocale");
    }
            
    public inline function createRainbowMainMenu():Popup_RainbowMainMenu {
        return this.create("RainbowMainMenu");
    }
            
    public inline function createStarCurrency():Popup_StarCurrency {
        return this.create("StarCurrency");
    }
            
    public inline function createManHair():Popup_ManHair {
        return this.create("ManHair");
    }
            
    public inline function createCorner():Popup_Corner {
        return this.create("Corner");
    }
            
    public inline function createPopup_fla_headShop_funnyHead_43():Popup_Popup_fla_headShop_funnyHead_43 {
        return this.create("Popup_fla.headShop_funnyHead_43");
    }
            
    public inline function createMC_ChopperRotor():Popup_MC_ChopperRotor {
        return this.create("MC_ChopperRotor");
    }
            
    public inline function createPopupShop():Popup_PopupShop {
        return this.create("PopupShop");
    }
            
    public inline function createPopupHalfShop():Popup_PopupHalfShop {
        return this.create("PopupHalfShop");
    }
            
    public inline function createBalloon_cord():Popup_Balloon_cord {
        return this.create("balloon_cord");
    }
            
    public inline function createManMouth():Popup_ManMouth {
        return this.create("ManMouth");
    }
            
    public inline function createPinCloud1():Popup_PinCloud1 {
        return this.create("PinCloud1");
    }
            
    public inline function createBalloon_stroked():Popup_Balloon_stroked {
        return this.create("balloon_stroked");
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
        File.loadBytes("" + path + "Popup.swfty", function(bytes) {
            this.loadBytes(bytes, onComplete, onError);
        }, onError);
    }


    inline function _loadBytes(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        this.loadBytes(bytes, onComplete, onError);
    }

    public static inline function load(?quality:Quality, ?width:Int, ?height:Int, ?bytes:Bytes, ?onComplete:Popup->Void, ?onError:Dynamic->Void):Popup {
        if (quality == null) quality = Normal;
        var layer:Popup = Layer.empty(width, height);
        if (bytes != null) {
            layer._loadBytes(bytes, function() if (onComplete != null) onComplete(layer), onError);
        } else {
            layer._load(quality, function() if (onComplete != null) onComplete(layer), onError);
        }
        return layer;
    }

    public static inline function create(?width:Int, ?height:Int):Popup {
        return Layer.empty(width, height);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BaloonHighlight(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BaloonHighlight {
        return layer.createBaloonHighlight();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ShopItems(Sprite) from Sprite to Sprite {
    
    public var item0(get, never):Popup_ItemShop;
    public inline function get_item0():Popup_ItemShop {
        return this.get("item0");
    }
                        
    public var item1(get, never):Popup_ItemShop;
    public inline function get_item1():Popup_ItemShop {
        return this.get("item1");
    }
                        
    public var item2(get, never):Popup_ItemShop;
    public inline function get_item2():Popup_ItemShop {
        return this.get("item2");
    }
                        
    public var item3(get, never):Popup_ItemShop;
    public inline function get_item3():Popup_ItemShop {
        return this.get("item3");
    }
                        
    public var item4(get, never):Popup_ItemShop;
    public inline function get_item4():Popup_ItemShop {
        return this.get("item4");
    }
                        
    public var item5(get, never):Popup_ItemShop;
    public inline function get_item5():Popup_ItemShop {
        return this.get("item5");
    }
                        
    public var item6(get, never):Popup_ItemShop;
    public inline function get_item6():Popup_ItemShop {
        return this.get("item6");
    }
                        
    public var item7(get, never):Popup_ItemShop;
    public inline function get_item7():Popup_ItemShop {
        return this.get("item7");
    }
                        
    public var item8(get, never):Popup_ItemShop;
    public inline function get_item8():Popup_ItemShop {
        return this.get("item8");
    }
                        
    public var item9(get, never):Popup_ItemShop;
    public inline function get_item9():Popup_ItemShop {
        return this.get("item9");
    }
                        
    public var item10(get, never):Popup_ItemShop;
    public inline function get_item10():Popup_ItemShop {
        return this.get("item10");
    }
                        
    public var item11(get, never):Popup_ItemShop;
    public inline function get_item11():Popup_ItemShop {
        return this.get("item11");
    }
                        
    public static inline function create(layer:Popup):Popup_ShopItems {
        return layer.createShopItems();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ItemShop(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Popup_Icon_shopItem;
    public inline function get_icon():Popup_Icon_shopItem {
        return this.get("icon");
    }
                        
    public var price(get, never):Text;
    public inline function get_price():Text {
        return this.getText("price");
    }
                        
    public var over(get, never):Popup_IconOverlay;
    public inline function get_over():Popup_IconOverlay {
        return this.get("over");
    }
                        
    public var sold(get, never):Popup_Sold;
    public inline function get_sold():Popup_Sold {
        return this.get("sold");
    }
                        
    public static inline function create(layer:Popup):Popup_ItemShop {
        return layer.createItemShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_red(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_red {
        return layer.createBalloon_red();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Popup_Closebutton(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Popup_Closebutton {
        return layer.createPopup_Closebutton();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloons(Sprite) from Sprite to Sprite {
    
    public var b12(get, never):Popup_Balloon_cord_stroke;
    public inline function get_b12():Popup_Balloon_cord_stroke {
        return this.get("b12");
    }
                        
    public var b11(get, never):Popup_Balloon_cord;
    public inline function get_b11():Popup_Balloon_cord {
        return this.get("b11");
    }
                        
    public var b10(get, never):Popup_Balloon_stroked;
    public inline function get_b10():Popup_Balloon_stroked {
        return this.get("b10");
    }
                        
    public var b9(get, never):Popup_Balloon_orange;
    public inline function get_b9():Popup_Balloon_orange {
        return this.get("b9");
    }
                        
    public var b8(get, never):Popup_Balloon_stroked;
    public inline function get_b8():Popup_Balloon_stroked {
        return this.get("b8");
    }
                        
    public var b7(get, never):Popup_Balloon_red;
    public inline function get_b7():Popup_Balloon_red {
        return this.get("b7");
    }
                        
    public var s1(get, never):Popup_BaloonHighlight;
    public inline function get_s1():Popup_BaloonHighlight {
        return this.get("s1");
    }
                        
    public var b6(get, never):Popup_Balloon_stroked;
    public inline function get_b6():Popup_Balloon_stroked {
        return this.get("b6");
    }
                        
    public var b5(get, never):Popup_Balloon_blue;
    public inline function get_b5():Popup_Balloon_blue {
        return this.get("b5");
    }
                        
    public var s3(get, never):Popup_BaloonHighlight;
    public inline function get_s3():Popup_BaloonHighlight {
        return this.get("s3");
    }
                        
    public var b4(get, never):Popup_Balloon_stroked;
    public inline function get_b4():Popup_Balloon_stroked {
        return this.get("b4");
    }
                        
    public var b3(get, never):Popup_Balloon_yellow;
    public inline function get_b3():Popup_Balloon_yellow {
        return this.get("b3");
    }
                        
    public var s2(get, never):Popup_BaloonHighlight;
    public inline function get_s2():Popup_BaloonHighlight {
        return this.get("s2");
    }
                        
    public var b2(get, never):Popup_Balloon_stroked;
    public inline function get_b2():Popup_Balloon_stroked {
        return this.get("b2");
    }
                        
    public var b1(get, never):Popup_Balloon_red;
    public inline function get_b1():Popup_Balloon_red {
        return this.get("b1");
    }
                        
    public var s4(get, never):Popup_BaloonHighlight;
    public inline function get_s4():Popup_BaloonHighlight {
        return this.get("s4");
    }
                        
    public static inline function create(layer:Popup):Popup_Balloons {
        return layer.createBalloons();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_TitleHead(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_TitleHead {
        return layer.createTitleHead();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_MC_ChopperBody(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_MC_ChopperBody {
        return layer.createMC_ChopperBody();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Popup_fla_headShop_smashRainbow_23(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Popup_fla_headShop_smashRainbow_23 {
        return layer.createPopup_fla_headShop_smashRainbow_23();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Sold(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Sold {
        return layer.createSold();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BGtitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BGtitle {
        return layer.createBGtitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BaloonShadowInn(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BaloonShadowInn {
        return layer.createBaloonShadowInn();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Popup_fla_headShop_smashChopper_26(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Popup_fla_headShop_smashChopper_26 {
        return layer.createPopup_fla_headShop_smashChopper_26();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ShopDescription(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Popup_Icon_shopItem;
    public inline function get_icon():Popup_Icon_shopItem {
        return this.get("icon");
    }
                        
    public var description(get, never):Text;
    public inline function get_description():Text {
        return this.getText("description");
    }
                        
    public var price(get, never):Text;
    public inline function get_price():Text {
        return this.getText("price");
    }
                        
    public var title(get, never):Text;
    public inline function get_title():Text {
        return this.getText("title");
    }
                        
    public static inline function create(layer:Popup):Popup_ShopDescription {
        return layer.createShopDescription();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ManNose(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_ManNose {
        return layer.createManNose();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_orange(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_orange {
        return layer.createBalloon_orange();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_StarMini(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_StarMini {
        return layer.createStarMini();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Face(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Face {
        return layer.createFace();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BtnBack(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BtnBack {
        return layer.createBtnBack();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BtnBuy(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BtnBuy {
        return layer.createBtnBuy();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Icon_shopItem(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Icon_shopItem {
        return layer.createIcon_shopItem();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_blue(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_blue {
        return layer.createBalloon_blue();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_cord_stroke(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_cord_stroke {
        return layer.createBalloon_cord_stroke();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_yellow(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_yellow {
        return layer.createBalloon_yellow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_IconOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_IconOverlay {
        return layer.createIconOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BuyLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BuyLocale {
        return layer.createBuyLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_CurrencyBG(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_CurrencyBG {
        return layer.createCurrencyBG();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_PopupShopMC(Sprite) from Sprite to Sprite {
    
    public var total(get, never):Text;
    public inline function get_total():Text {
        return this.getText("total");
    }
                        
    public var closeButton(get, never):Popup_Popup_Closebutton;
    public inline function get_closeButton():Popup_Popup_Closebutton {
        return this.get("closeButton");
    }
                        
    public var buyButton(get, never):Popup_BtnBuy;
    public inline function get_buyButton():Popup_BtnBuy {
        return this.get("buyButton");
    }
                        
    public var buyLocale(get, never):Popup_BuyLocale;
    public inline function get_buyLocale():Popup_BuyLocale {
        return this.get("buyLocale");
    }
                        
    public var backButton(get, never):Popup_BtnBack;
    public inline function get_backButton():Popup_BtnBack {
        return this.get("backButton");
    }
                        
    public var backLocale(get, never):Popup_BackLocale;
    public inline function get_backLocale():Popup_BackLocale {
        return this.get("backLocale");
    }
                        
    public var buyButtonOverlay(get, never):Popup_BtnBuyOverlay;
    public inline function get_buyButtonOverlay():Popup_BtnBuyOverlay {
        return this.get("buyButtonOverlay");
    }
                        
    public var items(get, never):Popup_ShopItems;
    public inline function get_items():Popup_ShopItems {
        return this.get("items");
    }
                        
    public var description(get, never):Popup_ShopDescription;
    public inline function get_description():Popup_ShopDescription {
        return this.get("description");
    }
                        
    public static inline function create(layer:Popup):Popup_PopupShopMC {
        return layer.createPopupShopMC();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ShopTitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_ShopTitle {
        return layer.createShopTitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BtnBuyOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BtnBuyOverlay {
        return layer.createBtnBuyOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_BackLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_BackLocale {
        return layer.createBackLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_RainbowMainMenu(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_RainbowMainMenu {
        return layer.createRainbowMainMenu();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_StarCurrency(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_StarCurrency {
        return layer.createStarCurrency();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ManHair(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_ManHair {
        return layer.createManHair();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Corner(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Corner {
        return layer.createCorner();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Popup_fla_headShop_funnyHead_43(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Popup_fla_headShop_funnyHead_43 {
        return layer.createPopup_fla_headShop_funnyHead_43();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_MC_ChopperRotor(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_MC_ChopperRotor {
        return layer.createMC_ChopperRotor();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_PopupShop(Sprite) from Sprite to Sprite {
    
    public var c1(get, never):Popup_Corner;
    public inline function get_c1():Popup_Corner {
        return this.get("c1");
    }
                        
    public var c2(get, never):Popup_Corner;
    public inline function get_c2():Popup_Corner {
        return this.get("c2");
    }
                        
    public var c3(get, never):Popup_Corner;
    public inline function get_c3():Popup_Corner {
        return this.get("c3");
    }
                        
    public var c4(get, never):Popup_Corner;
    public inline function get_c4():Popup_Corner {
        return this.get("c4");
    }
                        
    public var mc(get, never):Popup_PopupShopMC;
    public inline function get_mc():Popup_PopupShopMC {
        return this.get("mc");
    }
                        
    public static inline function create(layer:Popup):Popup_PopupShop {
        return layer.createPopupShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_PopupHalfShop(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_PopupHalfShop {
        return layer.createPopupHalfShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_cord(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_cord {
        return layer.createBalloon_cord();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_ManMouth(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_ManMouth {
        return layer.createManMouth();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_PinCloud1(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_PinCloud1 {
        return layer.createPinCloud1();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, loaded, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Balloon_stroked(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Balloon_stroked {
        return layer.createBalloon_stroked();
    }
}
                