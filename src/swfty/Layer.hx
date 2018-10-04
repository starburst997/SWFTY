
package swfty;

#if openfl
typedef Layer = swfty.openfl.Layer;
#else
#error 'Unsupported framework (please use OpenFL)'
#end