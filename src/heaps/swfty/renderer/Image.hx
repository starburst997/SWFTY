/**
 *  Stolen from hxd.res.Image, would be probably a nice PR since it's very usefull to transform a Bytes to Texture 
 **/
package heaps.swfty.renderer;

import haxe.io.Bytes;
import haxe.io.BytesInput;

import hxd.Pixels;
import hxd.PixelFormat;
import hxd.res.NanoJpeg;

using haxe.io.Path;

@:enum abstract ImageFormat(Int) {

	var Jpg = 0;
	var Png = 1;
	var Gif = 2;
	var Tga = 3;

	/*
		Tells if we might not be able to directly decode the image without going through a loadBitmap async call.
		This for example occurs when we want to decode progressive JPG in JS.
	*/
	public var useAsyncDecode(get, never) : Bool;

	inline function get_useAsyncDecode() {
		#if hl
		return false;
		#else
		return this == Jpg.toInt();
		#end
	}

	inline function toInt() return this;

}

class Image {

	/**
		Specify if we will automatically convert non-power-of-two textures to power-of-two.
	**/
	public static var ALLOW_NPOT = #if (flash && !flash11_8) false #else true #end;
	public static var DEFAULT_FILTER : h3d.mat.Data.Filter = Linear;

	/**
		Forces async decoding for images if available on the target platform.
	**/
	public static var DEFAULT_ASYNC = false;

    public var pixels:Pixels;

    var bytes:Bytes;
    var input:BytesInput;

	var tex:h3d.mat.Texture;
	var inf:{ width : Int, height : Int, format : ImageFormat };

    public static inline function create(bytes:Bytes) {
        return new Image(bytes);
    }

    public static function loadBytes( path:String, bytes:Bytes, onLoaded : Image -> Void ) : Void {
		#if flash
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e:flash.events.IOErrorEvent) {
			throw Std.string(e) + " while loading " + fullPath;
		});
		loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, function(_) {
			var content : flash.display.Bitmap = cast loader.content;
			onLoaded(new hxd.fs.LoadedBitmap(content.bitmapData));
			loader.unload();
		});
		loader.loadBytes(bytes.getData());
		#elseif js
        var image = new Image(bytes);
		var mime = switch path.extension().toLowerCase() {
			case 'jpg' | 'jpeg': 'image/jpeg';
			case 'png': 'image/png';
			case 'gif': 'image/gif';
			case _: throw 'Cannot determine image encoding, try adding an extension to the resource path';
		}
		var img = new js.html.Image();
		img.onload = function() {
            var bmp = new hxd.fs.LoadedBitmap(img).toBitmap();
            image.pixels = bmp.getPixels();
            onLoaded(image);
        };
		img.src = 'data:$mime;base64,' + haxe.crypto.Base64.encode(bytes);
		#else
		throw "Not implemented";
		#end
	}

    public function new(bytes:Bytes) {
        this.bytes = bytes;
        input = new BytesInput(bytes);
    }

	public function getFormat():ImageFormat {
		getSize();
		return inf.format;
	}

	public function getSize() : { width : Int, height : Int } {
		if( inf != null )
			return inf;
		var f = input;
		var width = 0, height = 0, format;
		var head = try f.readUInt16() catch( e : haxe.io.Eof ) 0;
		switch( head ) {
		case 0xD8FF: // JPG
			format = Jpg;
			f.bigEndian = true;
			while( true ) {
				switch( f.readUInt16() ) {
				case 0xFFC2, 0xFFC0:
					var len = f.readUInt16();
					var prec = f.readByte();
					height = f.readUInt16();
					width = f.readUInt16();
					break;
				default:
					f.position += f.readUInt16() - 2;
				}
			}
		case 0x5089: // PNG
			format = Png;
			f.bigEndian = true;
			f.position += 6; // header
			while( true ) {
				var dataLen = f.readInt32();
				if( f.readInt32() == ('I'.code << 24) | ('H'.code << 16) | ('D'.code << 8) | 'R'.code ) {
					width = f.readInt32();
					height = f.readInt32();
					break;
				}
				f.position += dataLen + 4; // CRC
			}
		case 0x4947: // GIF
			format = Gif;
			f.readInt32(); // skip
			width = f.readUInt16();
			height = f.readUInt16();

        // TODO: Support TGA
		/*case _ if( entry.extension == "tga" ):
			format = Tga;
			f.position += 10;
			width = f.readUInt16();
			height = f.readUInt16();*/

		default:
			throw "Unsupported texture format";
		}
		f.close();
		inf = { width : width, height : height, format : format };
		return inf;
	}

	public function getPixels( ?fmt : PixelFormat, ?flipY : Bool ) {
		getSize();
		var pixels : hxd.Pixels;
		switch( inf.format ) {
		case Png:
			#if (lime && (cpp || neko || nodejs))
			// native PNG loader is faster
			var i = lime.graphics.Image.fromBytes( bytes );
			pixels = new Pixels(inf.width, inf.height, i.data.toBytes(), RGBA );
			#elseif hl
			if( fmt == null ) fmt = BGRA;
			pixels = decodePNG(bytes, inf.width, inf.height, fmt, flipY);
			if( pixels == null ) throw "Failed to decode PNG";
			#else
			var png = new format.png.Reader(new haxe.io.BytesInput(bytes));
			png.checkCRC = false;
			pixels = Pixels.alloc(inf.width, inf.height, BGRA);
			#if( format >= "3.1.3" )
			var pdata = png.read();
			format.png.Tools.extract32(pdata, pixels.bytes, flipY);
			if( flipY ) pixels.flags.set(FlipY);
			#else
			format.png.Tools.extract32(png.read(), pixels.bytes);
			#end
			#end
		case Gif:
			var gif = new format.gif.Reader(new haxe.io.BytesInput(bytes)).read();
			pixels = new Pixels(inf.width, inf.height, format.gif.Tools.extractFullBGRA(gif, 0), BGRA);
		case Jpg:
			#if hl
			if( fmt == null ) fmt = BGRA;
			pixels = decodeJPG(bytes, inf.width, inf.height, fmt, flipY);
			if( pixels == null ) throw "Failed to decode JPG";
			#else
			var p = try NanoJpeg.decode(bytes) catch( e : Dynamic ) throw "Failed to decode JPG (" + e+")";
			pixels = new Pixels(p.width, p.height, p.pixels, BGRA);
			#end
		case Tga:
			var r = new format.tga.Reader(new haxe.io.BytesInput(bytes)).read();
			if( r.header.imageType != UncompressedTrueColor || r.header.bitsPerPixel != 32 )
				throw "Not supported "+r.header.imageType+"/"+r.header.bitsPerPixel;
			var w = r.header.width;
			var h = r.header.height;
			pixels = hxd.Pixels.alloc(w, h, ARGB);
			var access : hxd.Pixels.PixelsARGB = pixels;
			var p = 0;
			for( y in 0...h )
				for( x in 0...w ) {
					var c = r.imageData[x + y * w];
					access.setPixel(x, y, c);
				}
			switch( r.header.imageOrigin ) {
			case BottomLeft: pixels.flags.set(FlipY);
			case TopLeft: // nothing
			default: throw "Not supported "+r.header.imageOrigin;
			}
		}
		if( fmt != null ) pixels.convert(fmt);
		if( flipY != null ) pixels.setFlip(flipY);
		return pixels;
	}

	#if hl
	static function decodeJPG( src : haxe.io.Bytes, width : Int, height : Int, fmt : hxd.PixelFormat, flipY : Bool ) {
		var ifmt : hl.Format.PixelFormat = switch( fmt ) {
		case RGBA: RGBA;
		case BGRA: BGRA;
		case ARGB: ARGB;
		default:
			fmt = BGRA;
			BGRA;
		};
		var dst = haxe.io.Bytes.alloc(width * height * 4);
		if( !hl.Format.decodeJPG(src.getData(), src.length, dst.getData(), width, height, width * 4, ifmt, (flipY?1:0)) )
			return null;
		var pix = new hxd.Pixels(width, height, dst, fmt);
		if( flipY ) pix.flags.set(FlipY);
		return pix;
	}

	static function decodePNG( src : haxe.io.Bytes, width : Int, height : Int, fmt : hxd.PixelFormat, flipY : Bool ) {
		var ifmt : hl.Format.PixelFormat = switch( fmt ) {
		case RGBA: RGBA;
		case BGRA: BGRA;
		case ARGB: ARGB;
		default:
			fmt = BGRA;
			BGRA;
		};
		var dst = haxe.io.Bytes.alloc(width * height * 4);
		if( !hl.Format.decodePNG(src.getData(), src.length, dst.getData(), width, height, width * 4, ifmt, (flipY?1:0)) )
			return null;
		var pix = new hxd.Pixels(width, height, dst, fmt);
		if( flipY ) pix.flags.set(FlipY);
		return pix;
	}
	#end

	public function toBitmap() : hxd.BitmapData {
		getSize();
		var bmp = new hxd.BitmapData(inf.width, inf.height);
		var pixels = getPixels();
		bmp.setPixels(pixels);
		pixels.dispose();
		return bmp;
	}

	function watchCallb() {
		var w = inf.width, h = inf.height;
		inf = null;
		var s = getSize();
		if( w != s.width || h != s.height )
			tex.resize(w, h);
		tex.realloc = null;
		loadTexture();
	}

	function loadTexture() {
		if( !getFormat().useAsyncDecode && !DEFAULT_ASYNC ) {
			// immediately loading the PNG is faster than going through loadBitmap
            tex.alloc();
            var pixels = this.pixels != null ? this.pixels : getPixels(h3d.mat.Texture.nativeFormat);
            if( pixels.width != tex.width || pixels.height != tex.height )
                pixels.makeSquare();
            tex.uploadPixels(pixels);
            pixels.dispose();
            tex.realloc = loadTexture;
		} else {
			throw 'Not implemented!';
		}
	}

	public function toTexture() : h3d.mat.Texture {
		if( tex != null )
			return tex;
		getSize();
		var width = inf.width, height = inf.height;
		if( !ALLOW_NPOT ) {
			var tw = 1, th = 1;
			while( tw < width ) tw <<= 1;
			while( th < height ) th <<= 1;
			width = tw;
			height = th;
		}
		tex = new h3d.mat.Texture(width, height, [NoAlloc]);
		if( DEFAULT_FILTER != Linear ) tex.filter = DEFAULT_FILTER;
		loadTexture();
		return tex;
	}

	public function toTile() : h2d.Tile {
		var size = getSize();
		return h2d.Tile.fromTexture(toTexture()).sub(0, 0, size.width, size.height);
	}

}
