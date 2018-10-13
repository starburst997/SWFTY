package swfty.openfl;

import format.swf.tags.IDefinitionTag;

class Bitmap extends flash.display.Bitmap {
	
	public function new(exporter:Exporter, tag:IDefinitionTag) {		
		super ();
		
		bitmapData = exporter.bitmapDatas.get(tag.characterId);
	}
}