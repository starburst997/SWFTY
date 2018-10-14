package swfty.renderer;

#if openfl
typedef Sprite = openfl.swfty.renderer.Sprite;
#else
#error 'Unsupported framework (please use OpenFL)'
#end