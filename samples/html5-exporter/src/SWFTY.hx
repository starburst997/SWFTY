package;

#if html5
import swfty.exporter.Exporter;

import haxe.io.Bytes;
import haxe.io.BytesData;

import js.html.ArrayBuffer;

@:keep @:expose
class SWFTY {

	function new() { }

	public static function processSWF(bytes:ArrayBuffer, ?name:String, ?onComplete:Exporter->Void, ?onError:Dynamic->Void) {
		var timer = haxe.Timer.stamp();
		Exporter.create(Bytes.ofData(bytes), new haxe.io.Path(name).file, function(exporter) {
            trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
            if (onComplete != null) onComplete(exporter);
        });
	}

	public static function convertSWF(bytes:ArrayBuffer, ?name:String, ?onComplete:BytesData->Void, ?onError:Dynamic->Void, ?useJson:Bool = false, ?compressed:Bool = true) {
		processSWF(bytes, name, function(exporter) {
			exportSWF(exporter, onComplete, useJson, compressed);
		}, onError);
	}

	public static function exportSWF(exporter:Exporter, ?onComplete:BytesData->Void, ?useJson:Bool = false, ?compressed:Bool = true) {
		var swfty = exporter.getSwfty(useJson, compressed);
		if (onComplete != null) onComplete(swfty.getData());
	}

	public static function exportAbstracts(exporter:Exporter) {
		var abstracts = exporter.getAbstracts();
		return abstracts;
	}

	public static function renderSWFTY(bytes:ArrayBuffer, ?onComplete:Layer->Void, ?onError:Dynamic->Void) {
		if (Main.instance != null) Main.instance.renderSWFTY(Bytes.ofData(bytes), onComplete, onError);
	}
}
#end