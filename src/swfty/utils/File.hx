package swfty.utils;

#if (macro || void)
typedef File = void.swfty.utils.File;
#elseif openfl
typedef File = openfl.swfty.utils.File;
#elseif heaps
typedef File = heaps.swfty.utils.File;
#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end