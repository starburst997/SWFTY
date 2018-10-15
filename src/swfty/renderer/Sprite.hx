package swfty.renderer;

#if openfl
typedef Sprite = openfl.swfty.renderer.Sprite;
#elseif heaps
typedef Sprite = heaps.swfty.renderer.Sprite;
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end