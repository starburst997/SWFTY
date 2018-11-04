package swfty.renderer;

#if openfl
typedef EngineText = openfl.swfty.renderer.Text;

@:forward(x, y, scaleX, scaleY, rotation, text)
abstract Text(EngineText) from EngineText to EngineText {
    
}
#elseif heaps
typedef EngineText = heaps.swfty.renderer.Text;

@:forward(x, y, scaleX, scaleY, rotation, text)
abstract Text(EngineText) from EngineText to EngineText {
    
}
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end