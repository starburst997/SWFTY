package swfty;

import haxe.io.Bytes;

import swfty.utils.File;
import swfty.renderer.Sprite;
import swfty.renderer.Text;
import swfty.renderer.Layer;

/** This file is auto-generated! **/

@:forward(x, y, scaleX, scaleY, rotation, alpha, getAllNames, get, add, remove)
abstract Popup(Layer) from Layer to Layer {
    
    public inline function getManNose():ManNose {
        return this.get("ManNose");
    }
            
    public inline function getManMouth():ManMouth {
        return this.get("ManMouth");
    }
            
    public inline function getManHair():ManHair {
        return this.get("ManHair");
    }
            
    public inline function getFace():Face {
        return this.get("Face");
    }
            
    public inline function getBGtitle():BGtitle {
        return this.get("BGtitle");
    }
            
    public inline function getTitleHead():TitleHead {
        return this.get("TitleHead");
    }
            
    public inline function getRainbowMainMenu():RainbowMainMenu {
        return this.get("RainbowMainMenu");
    }
            
    public inline function getPopup_fla_headShop_smashRainbow_23():Popup_fla_headShop_smashRainbow_23 {
        return this.get("Popup_fla.headShop_smashRainbow_23");
    }
            
    public inline function getMC_ChopperBody():MC_ChopperBody {
        return this.get("MC_ChopperBody");
    }
            
    public inline function getMC_ChopperRotor():MC_ChopperRotor {
        return this.get("MC_ChopperRotor");
    }
            
    public inline function getPopup_fla_headShop_smashChopper_26():Popup_fla_headShop_smashChopper_26 {
        return this.get("Popup_fla.headShop_smashChopper_26");
    }
            
    public inline function getPinCloud1():PinCloud1 {
        return this.get("PinCloud1");
    }
            
    public inline function getBalloon_cord_stroke():Balloon_cord_stroke {
        return this.get("balloon_cord_stroke");
    }
            
    public inline function getBalloon_cord():Balloon_cord {
        return this.get("balloon_cord");
    }
            
    public inline function getBalloon_stroked():Balloon_stroked {
        return this.get("balloon_stroked");
    }
            
    public inline function getBalloon_orange():Balloon_orange {
        return this.get("balloon_orange");
    }
            
    public inline function getBaloonShadowInn():BaloonShadowInn {
        return this.get("BaloonShadowInn");
    }
            
    public inline function getBalloon_red():Balloon_red {
        return this.get("balloon_red");
    }
            
    public inline function getBaloonHighlight():BaloonHighlight {
        return this.get("BaloonHighlight");
    }
            
    public inline function getBalloon_blue():Balloon_blue {
        return this.get("balloon_blue");
    }
            
    public inline function getBalloon_yellow():Balloon_yellow {
        return this.get("balloon_yellow");
    }
            
    public inline function getBalloons():Balloons {
        return this.get("Balloons");
    }
            
    public inline function getPopup_fla_headShop_funnyHead_43():Popup_fla_headShop_funnyHead_43 {
        return this.get("Popup_fla.headShop_funnyHead_43");
    }
            
    public inline function getStarCurrency():StarCurrency {
        return this.get("StarCurrency");
    }
            
    public inline function getStarMini():StarMini {
        return this.get("StarMini");
    }
            
    public inline function getIcon_shopItem():Icon_shopItem {
        return this.get("icon_shopItem");
    }
            
    public inline function getShopDescription():ShopDescription {
        return this.get("ShopDescription");
    }
            
    public inline function getSold():Sold {
        return this.get("Sold");
    }
            
    public inline function getIconOverlay():IconOverlay {
        return this.get("iconOverlay");
    }
            
    public inline function getItemShop():ItemShop {
        return this.get("ItemShop");
    }
            
    public inline function getShopItems():ShopItems {
        return this.get("ShopItems");
    }
            
    public inline function getBackLocale():BackLocale {
        return this.get("BackLocale");
    }
            
    public inline function getBuyLocale():BuyLocale {
        return this.get("BuyLocale");
    }
            
    public inline function getPopup_Closebutton():Popup_Closebutton {
        return this.get("Popup_Closebutton");
    }
            
    public inline function getShopTitle():ShopTitle {
        return this.get("ShopTitle");
    }
            
    public inline function getCurrencyBG():CurrencyBG {
        return this.get("CurrencyBG");
    }
            
    public inline function getPopupHalfShop():PopupHalfShop {
        return this.get("PopupHalfShop");
    }
            
    public inline function getBtnBuy():BtnBuy {
        return this.get("BtnBuy");
    }
            
    public inline function getBtnBack():BtnBack {
        return this.get("BtnBack");
    }
            
    public inline function getBtnBuyOverlay():BtnBuyOverlay {
        return this.get("BtnBuyOverlay");
    }
            
    public inline function getPopupShopMC():PopupShopMC {
        return this.get("PopupShopMC");
    }
            
    public inline function getCorner():Corner {
        return this.get("Corner");
    }
            
    public inline function getPopupShop():PopupShop {
        return this.get("PopupShop");
    }
            
    public inline function reload(?bytes:Bytes, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete() {
            this.reload();
            if (onComplete != null) onComplete();
        }
        
        if (bytes != null) {
            this.load(bytes, complete, onError);
        } else {
            load(complete, onError);
        }
    }

    public inline function load(?onComplete:Void->Void, ?onError:Dynamic->Void) {
        File.loadBytes("Popup.swfty", bytes -> {
            this.load(bytes, () -> {
                if (onComplete != null) onComplete();
            }, onError);
        }, onError);
    }

    public static inline function create(?width:Int, ?height:Int, ?onComplete:Popup->Void, ?onError:Dynamic->Void):Popup {
        var layer:Popup = Layer.create(width, height);
        layer.load(() -> if (onComplete != null) onComplete(layer), onError);
        return layer;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ManNose(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManNose {
        return layer.getManNose();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ManMouth(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManMouth {
        return layer.getManMouth();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ManHair(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ManHair {
        return layer.getManHair();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Face(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Face {
        return layer.getFace();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BGtitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BGtitle {
        return layer.getBGtitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract TitleHead(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):TitleHead {
        return layer.getTitleHead();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract RainbowMainMenu(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):RainbowMainMenu {
        return layer.getRainbowMainMenu();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Popup_fla_headShop_smashRainbow_23(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_smashRainbow_23 {
        return layer.getPopup_fla_headShop_smashRainbow_23();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract MC_ChopperBody(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):MC_ChopperBody {
        return layer.getMC_ChopperBody();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract MC_ChopperRotor(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):MC_ChopperRotor {
        return layer.getMC_ChopperRotor();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Popup_fla_headShop_smashChopper_26(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_smashChopper_26 {
        return layer.getPopup_fla_headShop_smashChopper_26();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract PinCloud1(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):PinCloud1 {
        return layer.getPinCloud1();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_cord_stroke(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_cord_stroke {
        return layer.getBalloon_cord_stroke();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_cord(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_cord {
        return layer.getBalloon_cord();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_stroked(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_stroked {
        return layer.getBalloon_stroked();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_orange(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_orange {
        return layer.getBalloon_orange();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BaloonShadowInn(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BaloonShadowInn {
        return layer.getBaloonShadowInn();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_red(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_red {
        return layer.getBalloon_red();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BaloonHighlight(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BaloonHighlight {
        return layer.getBaloonHighlight();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_blue(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_blue {
        return layer.getBalloon_blue();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloon_yellow(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Balloon_yellow {
        return layer.getBalloon_yellow();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Balloons(Sprite) from Sprite to Sprite {
    
    public var b12(get, never):Balloon_cord_stroke;
    public inline function get_b12() {
        return this.get("b12");
    }
                        
    public var b11(get, never):Balloon_cord;
    public inline function get_b11() {
        return this.get("b11");
    }
                        
    public var b10(get, never):Balloon_stroked;
    public inline function get_b10() {
        return this.get("b10");
    }
                        
    public var b9(get, never):Balloon_orange;
    public inline function get_b9() {
        return this.get("b9");
    }
                        
    public var b8(get, never):Balloon_stroked;
    public inline function get_b8() {
        return this.get("b8");
    }
                        
    public var b7(get, never):Balloon_red;
    public inline function get_b7() {
        return this.get("b7");
    }
                        
    public var s1(get, never):BaloonHighlight;
    public inline function get_s1() {
        return this.get("s1");
    }
                        
    public var b6(get, never):Balloon_stroked;
    public inline function get_b6() {
        return this.get("b6");
    }
                        
    public var b5(get, never):Balloon_blue;
    public inline function get_b5() {
        return this.get("b5");
    }
                        
    public var s3(get, never):BaloonHighlight;
    public inline function get_s3() {
        return this.get("s3");
    }
                        
    public var b4(get, never):Balloon_stroked;
    public inline function get_b4() {
        return this.get("b4");
    }
                        
    public var b3(get, never):Balloon_yellow;
    public inline function get_b3() {
        return this.get("b3");
    }
                        
    public var s2(get, never):BaloonHighlight;
    public inline function get_s2() {
        return this.get("s2");
    }
                        
    public var b2(get, never):Balloon_stroked;
    public inline function get_b2() {
        return this.get("b2");
    }
                        
    public var b1(get, never):Balloon_red;
    public inline function get_b1() {
        return this.get("b1");
    }
                        
    public var s4(get, never):BaloonHighlight;
    public inline function get_s4() {
        return this.get("s4");
    }
                        
    public static inline function create(layer:Popup):Balloons {
        return layer.getBalloons();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Popup_fla_headShop_funnyHead_43(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_fla_headShop_funnyHead_43 {
        return layer.getPopup_fla_headShop_funnyHead_43();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract StarCurrency(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):StarCurrency {
        return layer.getStarCurrency();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract StarMini(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):StarMini {
        return layer.getStarMini();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Icon_shopItem(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Icon_shopItem {
        return layer.getIcon_shopItem();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ShopDescription(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Icon_shopItem;
    public inline function get_icon() {
        return this.get("icon");
    }
                        
    public var description(get, never):Text;
    public inline function get_description() {
        return this.getText("description");
    }
                        
    public var price(get, never):Text;
    public inline function get_price() {
        return this.getText("price");
    }
                        
    public var title(get, never):Text;
    public inline function get_title() {
        return this.getText("title");
    }
                        
    public static inline function create(layer:Popup):ShopDescription {
        return layer.getShopDescription();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Sold(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Sold {
        return layer.getSold();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract IconOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):IconOverlay {
        return layer.getIconOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ItemShop(Sprite) from Sprite to Sprite {
    
    public var icon(get, never):Icon_shopItem;
    public inline function get_icon() {
        return this.get("icon");
    }
                        
    public var price(get, never):Text;
    public inline function get_price() {
        return this.getText("price");
    }
                        
    public var over(get, never):IconOverlay;
    public inline function get_over() {
        return this.get("over");
    }
                        
    public var sold(get, never):Sold;
    public inline function get_sold() {
        return this.get("sold");
    }
                        
    public static inline function create(layer:Popup):ItemShop {
        return layer.getItemShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ShopItems(Sprite) from Sprite to Sprite {
    
    public var item0(get, never):ItemShop;
    public inline function get_item0() {
        return this.get("item0");
    }
                        
    public var item1(get, never):ItemShop;
    public inline function get_item1() {
        return this.get("item1");
    }
                        
    public var item2(get, never):ItemShop;
    public inline function get_item2() {
        return this.get("item2");
    }
                        
    public var item3(get, never):ItemShop;
    public inline function get_item3() {
        return this.get("item3");
    }
                        
    public var item4(get, never):ItemShop;
    public inline function get_item4() {
        return this.get("item4");
    }
                        
    public var item5(get, never):ItemShop;
    public inline function get_item5() {
        return this.get("item5");
    }
                        
    public var item6(get, never):ItemShop;
    public inline function get_item6() {
        return this.get("item6");
    }
                        
    public var item7(get, never):ItemShop;
    public inline function get_item7() {
        return this.get("item7");
    }
                        
    public var item8(get, never):ItemShop;
    public inline function get_item8() {
        return this.get("item8");
    }
                        
    public var item9(get, never):ItemShop;
    public inline function get_item9() {
        return this.get("item9");
    }
                        
    public var item10(get, never):ItemShop;
    public inline function get_item10() {
        return this.get("item10");
    }
                        
    public var item11(get, never):ItemShop;
    public inline function get_item11() {
        return this.get("item11");
    }
                        
    public static inline function create(layer:Popup):ShopItems {
        return layer.getShopItems();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BackLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BackLocale {
        return layer.getBackLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BuyLocale(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BuyLocale {
        return layer.getBuyLocale();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Popup_Closebutton(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Popup_Closebutton {
        return layer.getPopup_Closebutton();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract ShopTitle(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):ShopTitle {
        return layer.getShopTitle();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract CurrencyBG(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):CurrencyBG {
        return layer.getCurrencyBG();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract PopupHalfShop(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):PopupHalfShop {
        return layer.getPopupHalfShop();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BtnBuy(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBuy {
        return layer.getBtnBuy();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BtnBack(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBack {
        return layer.getBtnBack();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract BtnBuyOverlay(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):BtnBuyOverlay {
        return layer.getBtnBuyOverlay();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract PopupShopMC(Sprite) from Sprite to Sprite {
    
    public var total(get, never):Text;
    public inline function get_total() {
        return this.getText("total");
    }
                        
    public var closeButton(get, never):Popup_Closebutton;
    public inline function get_closeButton() {
        return this.get("closeButton");
    }
                        
    public var buyButton(get, never):BtnBuy;
    public inline function get_buyButton() {
        return this.get("buyButton");
    }
                        
    public var buyLocale(get, never):BuyLocale;
    public inline function get_buyLocale() {
        return this.get("buyLocale");
    }
                        
    public var backButton(get, never):BtnBack;
    public inline function get_backButton() {
        return this.get("backButton");
    }
                        
    public var backLocale(get, never):BackLocale;
    public inline function get_backLocale() {
        return this.get("backLocale");
    }
                        
    public var buyButtonOverlay(get, never):BtnBuyOverlay;
    public inline function get_buyButtonOverlay() {
        return this.get("buyButtonOverlay");
    }
                        
    public var items(get, never):ShopItems;
    public inline function get_items() {
        return this.get("items");
    }
                        
    public var description(get, never):ShopDescription;
    public inline function get_description() {
        return this.get("description");
    }
                        
    public static inline function create(layer:Popup):PopupShopMC {
        return layer.getPopupShopMC();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract Corner(Sprite) from Sprite to Sprite {
    
    public static inline function create(layer:Popup):Corner {
        return layer.getCorner();
    }
}
                
@:forward(x, y, scaleX, scaleY, rotation, alpha, add, remove, get, getText)
abstract PopupShop(Sprite) from Sprite to Sprite {
    
    public var c1(get, never):Corner;
    public inline function get_c1() {
        return this.get("c1");
    }
                        
    public var c2(get, never):Corner;
    public inline function get_c2() {
        return this.get("c2");
    }
                        
    public var c3(get, never):Corner;
    public inline function get_c3() {
        return this.get("c3");
    }
                        
    public var c4(get, never):Corner;
    public inline function get_c4() {
        return this.get("c4");
    }
                        
    public var mc(get, never):PopupShopMC;
    public inline function get_mc() {
        return this.get("mc");
    }
                        
    public static inline function create(layer:Popup):PopupShop {
        return layer.getPopupShop();
    }
}
                