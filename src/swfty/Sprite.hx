
package swfty;

#if openfl
typedef Sprite = swfty.openfl.Sprite;
#else
#error 'Unsupported framework (please use OpenFL)'
#end