
package swfty.renderer;

#if openfl
typedef Layer = openfl.swfty.renderer.Layer;
#elseif heaps
typedef Layer = heaps.swfty.renderer.Layer;
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end