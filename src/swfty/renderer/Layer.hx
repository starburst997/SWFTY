
package swfty.renderer;

#if openfl
typedef Layer = swfty.openfl.renderer.Layer;
#else
#error 'Unsupported framework (please use OpenFL)'
#end