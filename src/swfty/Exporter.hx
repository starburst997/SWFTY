package swfty;

#if openfl
typedef Exporter = swfty.openfl.Exporter;
#else
#error 'Unsupported framework (please use OpenFL)'
#end