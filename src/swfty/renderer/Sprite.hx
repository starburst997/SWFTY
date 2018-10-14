package swfty.renderer;

#if openfl
typedef Sprite = swfty.openfl.renderer.Sprite;
#else
#error 'Unsupported framework (please use OpenFL)'
#end