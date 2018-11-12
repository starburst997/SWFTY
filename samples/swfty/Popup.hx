package swfty;

import haxe.io.Bytes;

import swfty.utils.File;
import swfty.renderer.Sprite;
import swfty.renderer.Text;
import swfty.renderer.Layer;

/** This file is auto-generated! **/

@:forward(x, y, scaleX, scaleY, rotation, alpha, getAllNames, update, create, add, remove)
abstract Popup(Layer) from Layer to Layer {
    
    public inline function createManNose():ManNose {
        return this.create("ManNose");
    }
            
    public inline function createManMouth():ManMouth {
        return this.create("ManMouth");
    }
            
    public inline function createManHair():ManHair {
        return this.create("ManHair");
    }
            
    public inline function createFace():Face {
        return this.create("Face");
    }
            
    public inline function createBGtitle():BGtitle {
        return this.create("BGtitle");
    }
            
    public inline function createTitleHead():TitleHead {
        return this.create("TitleHead");
    }
            
    public inline function createRainbowMainMenu():RainbowMainMenu {
        return this.create("RainbowMainMenu");
    }
            
    public inline function createPopup_fla_headShop_smashRainbow_23():Popup_fla_headShop_smashRainbow_23 {
        return this.create("Popup_fla.headShop_smashRainbow_23");
    }
            
    public inline function createMC_ChopperBody():MC_ChopperBody {
        return this.create("MC_ChopperBody");
    }
            
    public inline function createMC_ChopperRotor():MC_ChopperRotor {
        return this.create("MC_ChopperRotor");
    }
            
    public inline function createPopup_fla_headShop_smashChopper_26():Popup_fla_headShop_smashChopper_26 {
        return this.create("Popup_fla.headShop_smashChopper_26");
    }
            
    public inline function createPinCloud1():PinCloud1 {
        return this.create("PinCloud1");
    }
            
    public inline function createBalloon_cord_stroke():Balloon_cord_stroke {
        return this.create("balloon_cord_stroke");
    }
            
    public inline function createBalloon_cord():Balloon_cord {
        return this.create("balloon_cord");
    }
            
    public inline function createBalloon_stroked():Balloon_stroked {
        return this.create("balloon_stroked");
    }
            
    public inline function createBalloon_orange():Balloon_orange {
        return this.create("balloon_orange");
    }
            
    public inline function createBaloonShadowInn():BaloonShadowInn {
        return this.create("BaloonShadowInn");
    }
            
    public inline function createBalloon_red():Balloon_red {
        return this.create("balloon_red");
    }
            
    public inline function createBaloonHighlight():BaloonHighlight {
        return this.create("BaloonHighlight");
    }
            
    public inline function createBalloon_blue():Balloon_blue {
        return this.create("balloon_blue");
    }
            
    public inline function createBalloon_yellow():Balloon_yellow {
        return this.create("balloon_yellow");
    }
            
    public inline function createBalloons():Balloons {
        return this.create("Balloons");
    }
            
    public inline function createPopup_fla_headShop_funnyHead_43():Popup_fla_headShop_funnyHead_43 {
        return this.create("Popup_fla.headShop_funnyHead_43");
    }
            
    public inline function createStarCurrency():StarCurrency {
        return this.create("StarCurrency");
    }
            
    public inline function createStarMini():StarMini {
        return this.create("StarMini");
    }
            
    public inline function createIcon_shopItem():Icon_shopItem {
        return this.create("icon_shopItem");
    }
            
    public inline function createShopDescription():ShopDescription {
        return this.create("ShopDescription");
    }
            
    public inline function createSold():Sold {
        return this.create("Sold");
    }
            
    public inline function createIconOverlay():IconOverlay {
        return this.create("iconOverlay");
    }
            
    public inline function createItemShop():ItemShop {
        return this.create("ItemShop");
    }
            
    public inline function createShopItems():ShopItems {
        return this.create("ShopItems");
    }
            
    public inline function createBackLocale():BackLocale {
        return this.create("BackLocale");
    }
            
    public inline function createBuyLocale():BuyLocale {
        return this.create("BuyLocale");
    }
            
    public inline function createPopup_Closebutton():Popup_Closebutton {
        return this.create("Popup_Closebutton");
    }
            
    public inline function createShopTitle():ShopTitle {
        return this.create("ShopTitle");
    }
            
    public inline function createCurrencyBG():CurrencyBG {
        return this.create("CurrencyBG");
    }
            
    public inline function createPopupHalfShop():PopupHalfShop {
        return this.create("PopupHalfShop");
    }
            
    public inline function createBtnBuy():BtnBuy {
        return this.create("BtnBuy");
    }
            
    public inline function createBtnBack():BtnBack {
        return this.create("BtnBack");
    }
            
    public inline function createBtnBuyOverlay():BtnBuyOverlay {
        return this.create("BtnBuyOverlay");
    }
            
    public inline function createPopupShopMC():PopupShopMC {
        return this.create("PopupShopMC");
    }
            
    public inline function createCorner():Corner {
        return this.create("Corner");
    }
            
    public inline function createPopupShop():PopupShop {
        return this.create("PopupShop");
    }
            
    public inline function reload(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete() {
            this.reload();
            if (onComplete != null) onComplete();
        }
        
        if (bytes != null) {
            this.loadBytes(bytes, complete, onError);
        } else {
            _load(complete, onError);
        }
    }

    inline function _load(?onComplete:Void->Void, ?onError:Dynamic->Void) {
        File.loadBytes("Popup.swfty", bytes -> {
            this.loadBytes(bytes, onComplete, onError);
        }, onError);
    }

    public static inline function load(?width:Int, ?height:Int, ?onComplete:Popup->Void, ?onError:Dynamic->Void):Popup {
        var layer:Popup = Layer.empty(width, height);
        layer._load(function() if (onComplete != null) onComplete(layer), onError);
        return layer;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ManNose(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManNose {
        return layer.createManNose();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ManMouth(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManMouth {
        return layer.createManMouth();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ManHair(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManHair {
        return layer.createManHair();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Face(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Face {
        return layer.createFace();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BGtitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BGtitle {
        return layer.createBGtitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract TitleHead(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):TitleHead {
        return layer.createTitleHead();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract RainbowMainMenu(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):RainbowMainMenu {
        return layer.createRainbowMainMenu();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_fla_headShop_smashRainbow_23(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_smashRainbow_23 {
        return layer.createPopup_fla_headShop_smashRainbow_23();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract MC_ChopperBody(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):MC_ChopperBody {
        return layer.createMC_ChopperBody();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract MC_ChopperRotor(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):MC_ChopperRotor {
        return layer.createMC_ChopperRotor();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_fla_headShop_smashChopper_26(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_smashChopper_26 {
        return layer.createPopup_fla_headShop_smashChopper_26();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract PinCloud1(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):PinCloud1 {
        return layer.createPinCloud1();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_cord_stroke(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_cord_stroke {
        return layer.createBalloon_cord_stroke();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_cord(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_cord {
        return layer.createBalloon_cord();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_stroked(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_stroked {
        return layer.createBalloon_stroked();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_orange(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_orange {
        return layer.createBalloon_orange();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BaloonShadowInn(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BaloonShadowInn {
        return layer.createBaloonShadowInn();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_red(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_red {
        return layer.createBalloon_red();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BaloonHighlight(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BaloonHighlight {
        return layer.createBaloonHighlight();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_blue(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_blue {
        return layer.createBalloon_blue();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloon_yellow(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_yellow {
        return layer.createBalloon_yellow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Balloons(Sprite) from Sprite to Sprite {
    
    public var b12(get, never):Balloon_cord_stroke;
    public inline function get_b12():Balloon_cord_stroke {
        return this.get("b12");
    }
                        
    public var b11(get, never):Balloon_cord;
    public inline function get_b11():Balloon_cord {
        return this.get("b11");
    }
                        
    public var b10(get, never):Balloon_stroked;
    public inline function get_b10():Balloon_stroked {
        return this.get("b10");
    }
                        
    public var b9(get, never):Balloon_orange;
    public inline function get_b9():Balloon_orange {
        return this.get("b9");
    }
                        
    public var b8(get, never):Balloon_stroked;
    public inline function get_b8():Balloon_stroked {
        return this.get("b8");
    }
                        
    public var b7(get, never):Balloon_red;
    public inline function get_b7():Balloon_red {
        return this.get("b7");
    }
                        
    public var s1(get, never):BaloonHighlight;
    public inline function get_s1():BaloonHighlight {
        return this.get("s1");
    }
                        
    public var b6(get, never):Balloon_stroked;
    public inline function get_b6():Balloon_stroked {
        return this.get("b6");
    }
                        
    public var b5(get, never):Balloon_blue;
    public inline function get_b5():Balloon_blue {
        return this.get("b5");
    }
                        
    public var s3(get, never):BaloonHighlight;
    public inline function get_s3():BaloonHighlight {
        return this.get("s3");
    }
                        
    public var b4(get, never):Balloon_stroked;
    public inline function get_b4():Balloon_stroked {
        return this.get("b4");
    }
                        
    public var b3(get, never):Balloon_yellow;
    public inline function get_b3():Balloon_yellow {
        return this.get("b3");
    }
                        
    public var s2(get, never):BaloonHighlight;
    public inline function get_s2():BaloonHighlight {
        return this.get("s2");
    }
                        
    public var b2(get, never):Balloon_stroked;
    public inline function get_b2():Balloon_stroked {
        return this.get("b2");
    }
                        
    public var b1(get, never):Balloon_red;
    public inline function get_b1():Balloon_red {
        return this.get("b1");
    }
                        
    public var s4(get, never):BaloonHighlight;
    public inline function get_s4():BaloonHighlight {
        return this.get("s4");
    }
                        
    public static inline function create(layer:Popup):Balloons {
        return layer.createBalloons();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_fla_headShop_funnyHead_43(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_funnyHead_43 {
        return layer.createPopup_fla_headShop_funnyHead_43();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract StarCurrency(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):StarCurrency {
        return layer.createStarCurrency();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract StarMini(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):StarMini {
        return layer.createStarMini();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Icon_shopItem(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Icon_shopItem {
        return layer.createIcon_shopItem();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ShopDescription(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Icon_shopItem;
    public inline function get_icon():Icon_shopItem {
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
                        
    public static inline function create(layer:Popup):ShopDescription {
        return layer.createShopDescription();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Sold(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Sold {
        return layer.createSold();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract IconOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):IconOverlay {
        return layer.createIconOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ItemShop(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Icon_shopItem;
    public inline function get_icon():Icon_shopItem {
        return this.get("icon");
    }
                        
    public var price(get, never):Text;
    public inline function get_price():Text {
        return this.getText("price");
    }
                        
    public var over(get, never):IconOverlay;
    public inline function get_over():IconOverlay {
        return this.get("over");
    }
                        
    public var sold(get, never):Sold;
    public inline function get_sold():Sold {
        return this.get("sold");
    }
                        
    public static inline function create(layer:Popup):ItemShop {
        return layer.createItemShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ShopItems(Sprite) from Sprite to Sprite {
    
    public var item0(get, never):ItemShop;
    public inline function get_item0():ItemShop {
        return this.get("item0");
    }
                        
    public var item1(get, never):ItemShop;
    public inline function get_item1():ItemShop {
        return this.get("item1");
    }
                        
    public var item2(get, never):ItemShop;
    public inline function get_item2():ItemShop {
        return this.get("item2");
    }
                        
    public var item3(get, never):ItemShop;
    public inline function get_item3():ItemShop {
        return this.get("item3");
    }
                        
    public var item4(get, never):ItemShop;
    public inline function get_item4():ItemShop {
        return this.get("item4");
    }
                        
    public var item5(get, never):ItemShop;
    public inline function get_item5():ItemShop {
        return this.get("item5");
    }
                        
    public var item6(get, never):ItemShop;
    public inline function get_item6():ItemShop {
        return this.get("item6");
    }
                        
    public var item7(get, never):ItemShop;
    public inline function get_item7():ItemShop {
        return this.get("item7");
    }
                        
    public var item8(get, never):ItemShop;
    public inline function get_item8():ItemShop {
        return this.get("item8");
    }
                        
    public var item9(get, never):ItemShop;
    public inline function get_item9():ItemShop {
        return this.get("item9");
    }
                        
    public var item10(get, never):ItemShop;
    public inline function get_item10():ItemShop {
        return this.get("item10");
    }
                        
    public var item11(get, never):ItemShop;
    public inline function get_item11():ItemShop {
        return this.get("item11");
    }
                        
    public static inline function create(layer:Popup):ShopItems {
        return layer.createShopItems();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BackLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BackLocale {
        return layer.createBackLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BuyLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BuyLocale {
        return layer.createBuyLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Popup_Closebutton(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Closebutton {
        return layer.createPopup_Closebutton();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract ShopTitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ShopTitle {
        return layer.createShopTitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract CurrencyBG(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):CurrencyBG {
        return layer.createCurrencyBG();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract PopupHalfShop(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):PopupHalfShop {
        return layer.createPopupHalfShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BtnBuy(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBuy {
        return layer.createBtnBuy();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BtnBack(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBack {
        return layer.createBtnBack();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract BtnBuyOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBuyOverlay {
        return layer.createBtnBuyOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract PopupShopMC(Sprite) from Sprite to Sprite {
    
    public var total(get, never):Text;
    public inline function get_total():Text {
        return this.getText("total");
    }
                        
    public var closeButton(get, never):Popup_Closebutton;
    public inline function get_closeButton():Popup_Closebutton {
        return this.get("closeButton");
    }
                        
    public var buyButton(get, never):BtnBuy;
    public inline function get_buyButton():BtnBuy {
        return this.get("buyButton");
    }
                        
    public var buyLocale(get, never):BuyLocale;
    public inline function get_buyLocale():BuyLocale {
        return this.get("buyLocale");
    }
                        
    public var backButton(get, never):BtnBack;
    public inline function get_backButton():BtnBack {
        return this.get("backButton");
    }
                        
    public var backLocale(get, never):BackLocale;
    public inline function get_backLocale():BackLocale {
        return this.get("backLocale");
    }
                        
    public var buyButtonOverlay(get, never):BtnBuyOverlay;
    public inline function get_buyButtonOverlay():BtnBuyOverlay {
        return this.get("buyButtonOverlay");
    }
                        
    public var items(get, never):ShopItems;
    public inline function get_items():ShopItems {
        return this.get("items");
    }
                        
    public var description(get, never):ShopDescription;
    public inline function get_description():ShopDescription {
        return this.get("description");
    }
                        
    public static inline function create(layer:Popup):PopupShopMC {
        return layer.createPopupShopMC();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract Corner(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Corner {
        return layer.createCorner();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, width, height, addRender, removeRender, get, getText)
abstract PopupShop(Sprite) from Sprite to Sprite {
    
    public var c1(get, never):Corner;
    public inline function get_c1():Corner {
        return this.get("c1");
    }
                        
    public var c2(get, never):Corner;
    public inline function get_c2():Corner {
        return this.get("c2");
    }
                        
    public var c3(get, never):Corner;
    public inline function get_c3():Corner {
        return this.get("c3");
    }
                        
    public var c4(get, never):Corner;
    public inline function get_c4():Corner {
        return this.get("c4");
    }
                        
    public var mc(get, never):PopupShopMC;
    public inline function get_mc():PopupShopMC {
        return this.get("mc");
    }
                        
    public static inline function create(layer:Popup):PopupShop {
        return layer.createPopupShop();
    }
}
                