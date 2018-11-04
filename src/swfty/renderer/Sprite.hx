package swfty.renderer;

// EngineSprite  = The class used in the underlying engine to display a container of objects, (ex: TileContainer in openfl)
// EngineBitmap  = The class used in the underlying engine to display a single image, (ex: Tile in openfl)
// DisplaySprite = An abstract over EngineSprite that allows a shared interfaces to easily share code betweem different engines
// DisplayBitmap = Same as above but for EngineBitmap
// FinalSprite   = An engine specific Sprite that extends BaseSprite (which extends EngineSprite)
// Sprite        = An abstract over FinalSprite that can be used over any engine

#if openfl
typedef EngineSprite = openfl.swfty.renderer.Sprite.EngineSprite;
typedef EngineBitmap = openfl.swfty.renderer.Sprite.EngineBitmap;
typedef DisplaySprite = openfl.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = openfl.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = openfl.swfty.renderer.Sprite.FinalSprite;
typedef Sprite = openfl.swfty.renderer.Sprite;

#elseif heaps
typedef EngineSprite = h2d.Object;
typedef EngineBitmap = heaps.swfty.renderer.Sprite.FinalSprite;
typedef DisplaySprite = heaps.swfty.renderer.Sprite.DisplaySprite;
typedef DisplayBitmap = heaps.swfty.renderer.Sprite.DisplayBitmap;
typedef FinalSprite = heaps.swfty.renderer.Sprite.FinalSprite;
typedef Sprite = heaps.swfty.renderer.Sprite;

#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end