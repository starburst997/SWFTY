package;

import haxe.Json;
import haxe.io.Bytes;

import haxe.net.WebSocket;
import haxe.net.WebSocketServer;

import swfty.exporter.Exporter;
import swfty.Structure;

import openfl.swfty.exporter.FontExporter;

import file.save.FileSave;

import hx.concurrent.executor.*;
import hx.files.*;
import hx.files.watcher.*;
import hx.concurrent.event.*;
import hx.concurrent.collection.*;

import openfl.events.Event;
import openfl.display.Sprite;

#if sys
/**
	Convert .SWF to .SWFTY
	Draw all shapes and bitmaps into one Spritesheet and save all symbol's 
    definitions into a binary file, the two files are then combined
    into a .ZIP file with the .SWFTY extension.
**/
class CLI extends mcli.CommandLine {

    /**
		Path of the SWFTY to save
        @alias o 
	**/
	public var output:String = null;

    /**
		Path of the font directory
        @alias f
	**/
	public var fontPath:String = null;

    /**
		Basis for relative path
        @alias r
	**/
	public var relPath:String = null;

    /**
		Watch for file changes (only works on folder)
        @alias w
	**/
	public var watch:Bool = false;

    var path:String = null;

	/**
		Show this message.
	**/
	public function help() {
		trace(this.showUsage());
		Sys.exit(0);
	}

    inline function getDir(path:String) {
        if (relPath != null) {
            return Path.of(relPath).join(path).normalize().toStringWithTrailingSeparator();
        }

        return Path.of(path).normalize().toStringWithTrailingSeparator();
    }

    inline function getFile(path:String) {
        if (relPath != null) {
            return Path.of(relPath).join(path).normalize().toString();
        }

        return Path.of(path).normalize().toString();
    }

    static inline function error(text:String) {
        Main.error(text);
    }

    static inline function log(text:String, ?info:String, ?depth = 1) {
        Main.log(text, info, depth);
    }

	public function runDefault(?path:String) {
        this.path = path;

		if(path == null) {
            // Look for swfty.json
            var bytes = File.of(getFile('swfty.json')).readAsBytes();
            if (bytes != null) {
                log('Found', getFile('swfty.json'), 0);
                loadConfig(bytes);
            } else {
                error('Please specify a folder to watch or a .SWF to convert or have a swfty.json file!');
                Sys.exit(0);
            }
        } else {
            
            var p = Path.of(path);
            if (p.filenameExt.toLowerCase() == 'swf') {
                // Convert single SWF
                // TODO: Clean this up
                log('Converting single file', '${p.toString()}');
                FontExporter.path = getDir(this.fontPath != null ? this.fontPath : FontExporter.path);
                processSWF(getFile(path), exporter -> {
                    var zip = exporter.getSwfty();
                    var output = this.output == null ? getFile(p.parent.join(p.filenameStem).toString() + '.swfty') : getDir(this.output);
                    if (Path.of(output).isDirectory()) {
                        output += Path.of(output).join(p.filenameStem + '.swfty').toString();
                    }

                    log('Saving', '$output', 2);
                    FileSave.writeBytes(zip, output);
                    
                    log('Done!');
                    Sys.exit(0);
                }, e -> {
                    error(e);
                    Sys.exit(0);
                });
            } else {
                // Look for a swfty.json in folder
                var bytes = File.of(p.join('swfty.json')).readAsBytes();
                if (bytes != null) {
                    log('Found', p.join('swfty.json').toString(), 0);
                    loadConfig(bytes);
                } else {
                    // Just watch folder using default config
                    processConfig(getConfig());
                }
            }
        }
	}

    function getConfig(?config:Config) {
        if (config == null) config = {};

        if (config.watch == null) config.watch = this.watch;
        if (config.watchFolder == null) config.watchFolder = 'res';
        if (config.outputFolder == null) config.outputFolder = config.watchFolder;
        if (config.fontFolder == null) config.fontFolder = FontExporter.path;
        if (config.quality == null) config.quality = [];
        if (config.pngquant == null) config.pngquant = true;
        if (config.fontEnabled == null) config.fontEnabled = true;
        if (config.sharedFonts == null) config.sharedFonts = false;
        if (config.maxDimension == null) config.maxDimension = null;
        if (config.files == null) config.files = [];

        // CLI arguments overwrite the config
        if (this.output != null) config.outputFolder = this.output;
        if (this.fontPath != null) config.fontFolder = this.fontPath;

        var output = Path.of(config.outputFolder);
        if (output.isFile()) config.outputFolder = output.parent.toString();

        FontExporter.path = getDir(config.fontFolder);

        log('Font path', FontExporter.path, 0);

        return config;
    }

    function loadConfig(bytes:Bytes) {
        try {
            if (bytes == null) throw 'no file';
            var config:Config = getConfig(haxe.Json.parse(bytes.toString()));

            processConfig(config);
        } catch(e:Dynamic) {
            error(e);
            Sys.exit(0);
        }
    }

    function listFiles(dir:Dir, ?ext:String = 'swf') {
        var files = [];
        var _listFiles = function f(_dir:Dir) {
            for (file in _dir.listFiles()) 
                if (ext == null || file.path.filenameExt.toLowerCase() == ext) 
                    files.push(file);
            for (dir in _dir.listDirs())
                f(dir);
        }
        _listFiles(dir);

        return files;
    }

    function processConfig(config:Config) {
        function convertSWF(path:Path, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
            log('Converting', path.toString());
            processSWF(path.toString(), exporter -> {
                log('Exporting', path.toString(), 2);

                var zip = exporter.getSwfty();
                var output = Path.of(getDir(config.outputFolder)).join(path.filenameStem + '.swfty').toString();

                var tilemap = exporter.getTilemap();
                log('Size', '${Math.ceil(zip.length / 1024 / 1024 * 100) / 100} MB', 2);
                log('Tilemap', '${tilemap.bitmapData.width}x${tilemap.bitmapData.height}', 2);

                // Makes sure dir exists
                Dir.of(Path.of(output).parent).create();

                log('Saving', '$output', 2);
                FileSave.writeBytes(zip, output);

                // Craft message to be sent to server
                var idBytes = Bytes.ofString(exporter.name);
                var messageBytes = Bytes.alloc(idBytes.length + 4 + zip.length);
                messageBytes.setInt32(0, idBytes.length);
                messageBytes.blit(4, idBytes, 0, idBytes.length);
                messageBytes.blit(idBytes.length + 4, zip, 0, zip.length);
                Main.swfs.add(messageBytes);

                log('Done!');
                
                if (onComplete != null) onComplete();
            }, onError);
        }

        if (config.watch) {
            // Look for all SWF in folder, convert any that don't have a "swfty" counter part
            var swfs = listFiles(Dir.of(getDir(config.outputFolder)));
            var swftys = [for (file in listFiles(Dir.of(getDir(config.outputFolder)), 'swfty')) file.path.filenameStem => false];

            for (swf in swfs) {
                if (swftys.exists(swf.path.filenameStem) && !swftys.get(swf.path.filenameStem)) {
                    // Convert SWF
                    convertSWF(swf.path);
                    swftys.set(swf.path.filenameStem, true);
                }
            }

            // Watch folder, processing any SWF
            var ex = Executor.create();
            var fw = new PollingFileWatcher(ex, 100);

            var timer:haxe.Timer = null;
            fw.subscribe(function (event) {
                switch(event) {
                    case FILE_MODIFIED(file, _) | FILE_CREATED(file) if (file.path.filenameExt.toLowerCase() == 'swf'): 

                        // Skip if too small
                        if (file.size() < 0x100) return;
                        
                        // Introduce a slight delay (sometimes multiple event can be fired quickly when publishing SWF)
                        if (timer != null) timer.stop();
                        timer = haxe.Timer.delay(() -> {
                            log('File modified', file.path.toString(), 0);
                            
                            timer.stop();
                            timer = null;

                            convertSWF(file.path);
                        }, 100);
                    case _ : 
                }
            });

            log('Watching', getDir(config.watchFolder), 0);
            fw.watch(getDir(config.watchFolder));

        } else {
            // Process entire folder conveerting all SWF
            var swfs = listFiles(Dir.of(getDir(config.outputFolder)));
            for (swf in swfs) {
                convertSWF(swf.path);
            }
        }
    }

    function processSWF(path:String, onComplete:Exporter->Void, onError:Dynamic->Void) {
		try {
            log('Loading', path, 2);

            var bytes = File.of(path).readAsBytes();
            if (bytes == null) throw 'File doesn\'t exists at $path';

            log('Loaded', '${Math.ceil(bytes.length/1024)} KB', 2);

			var timer = haxe.Timer.stamp();

            var id = path.substr(getDir('.').length);
			Exporter.create(bytes, id, function(exporter) {
                log('Parsed SWF', '${Math.ceil((haxe.Timer.stamp() - timer) * 100) / 100} sec', 2);
                onComplete(exporter);
            }, onError);
        } catch(e:Dynamic) {
            error(e);
            onError(e);
        }
	}
}
#end

class WebSocketHandler {
	static var _nextId = 0;
	var _id = _nextId++;
	var _websocket:WebSocket;
	
	public function new(websocket:WebSocket) {
		_websocket = websocket;
		_websocket.onopen = onopen;
		_websocket.onclose = onclose;
		_websocket.onerror = onerror;
		_websocket.onmessageBytes = onmessageBytes;
		_websocket.onmessageString = onmessageString;
	}
	
	public function update():Bool {
		_websocket.process();
		return _websocket.readyState != Closed;
	}
	
    function onopen():Void {
		Main.logs.add('$_id:open');
		_websocket.sendString('Get SWFTY!');
    }

    function onerror(message:String):Void {
		Main.logs.add('$_id:error: $message');
    }

    function onmessageString(message:String):Void {
		Main.logs.add('$_id:message: $message');
		_websocket.sendString(message);
    }

    function onmessageBytes(message:Bytes):Void {
		Main.logs.add('$_id:message bytes:' + message.toHex());
		_websocket.sendBytes(message);
    }

    public function sendBytes(message:Bytes) {
        _websocket.sendBytes(message);
    }

    public function sendString(message:String) {
        _websocket.sendString(message);
    }

    function onclose():Void {
		Main.logs.add('$_id:close');
    }
}

class Main extends Sprite {

    public static var id = 0;
    public static var swfs:SynchronizedArray<Bytes> = new SynchronizedArray();
    public static var logs:SynchronizedArray<String> = new SynchronizedArray();

    public static function error(text:String) {
        Console.log('<b>* Error: <#FF0000>$text</></>');
    }

    public static function log(text:String, ?info:String, ?depth = 1) {
        Console.log('<b>${[for (i in 0...Std.int(Math.max(depth - 1, 0))) '  '].join('')}${depth == 0 ? '' : '- '}$text</>${info == null ? '' : '<b>:</> <i>$info</>'}');
    }

	public function new() {	
		super();

        // Meh let's have some fun
        var color1 = '#00b3c4';
        var color2 = '#dbe688';
        var color3 = '#cccccc';
        Console.log("<" + color1 + ">                          ,d8888b</><" + color2 + ">                  </>");
        Console.log("<" + color1 + ">                          88P'   </><" + color2 + ">   d8P            </>");
        Console.log("<" + color1 + ">                       d888888P  </><" + color2 + ">d888888P          </>");
        Console.log("<" + color1 + "> .d888b, ?88   d8P  d8P  ?88'    </><" + color2 + ">  ?88'  ?88   d8P </>");
        Console.log("<" + color1 + "> ?8b,    d88  d8P' d8P'  88P     </><" + color2 + ">  88P   d88   88  </>");
        Console.log("<" + color1 + ">   `?8b  ?8b ,88b ,88'  d88      </><" + color2 + ">  88b   ?8(  d88  </>");
        Console.log("<" + color1 + ">`?888P'  `?888P'888P'  d88'      </><" + color2 + ">  `?8b  `?88P'?8b </>");
        Console.log("<" + color1 + ">                                 </><" + color2 + ">               )88</>");
        //Console.log("<" + color3 + ">    https://github.com/starburst997/SWFTY   </><" + color2 + ">   ,d8P</>");
        Console.log("<" + color3 + ">                                            </><" + color2 + ">   ,d8P</>");
        Console.log("<" + color1 + ">                                 </><" + color2 + ">           `?888P'</>");

        function showMeWhatYouGot(str:String) {
            var color1 = '#dfc24c';
            var color2 = '#f29941';
            str = str.replace('#', '<$color2>#</>');
            Console.log('<$color1>$str</>');
        }
        showMeWhatYouGot('      . -^   `--,      ');
        showMeWhatYouGot('     /# =========`-_   ');
        showMeWhatYouGot('    /# (--====___====\\ ');
        showMeWhatYouGot('   /#   .- --.  . --.| ');
        showMeWhatYouGot('  /##   |  * ) (   * ),');
        showMeWhatYouGot('  |##   \\    /\\ \\   / |');
        showMeWhatYouGot('  |###   ---   \\ ---  |');
        showMeWhatYouGot('  |####      ___)    #|');
        showMeWhatYouGot('  |######           ##|');
        showMeWhatYouGot('   \\##### ---------- / ');
        showMeWhatYouGot('    \\####           (  ');
        showMeWhatYouGot('     `\\###          |  ');
        showMeWhatYouGot('       \\###         |  ');
        showMeWhatYouGot('        \\##        |   ');
        showMeWhatYouGot('         \\###.    .)   ');
        showMeWhatYouGot('          `======/     ');
        
        Console.log('');
        Console.log('<b><$color1>SWFTY</></> <i><b>(</></><i>0.1.0</><i><b>)</></> by <b><i>Jean-Denis Boivin</></>');
        Console.log('');
        Console.log('<u>https://github.com/starburst997/SWFTY</>');
        Console.log('');

        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            // Do nothing!
        };

        #if sys
        // Start server
        var executor = Executor.create(1);
        var startServer = function():Void {

            var port = 0xC137;
            var server = WebSocketServer.create('0.0.0.0', port, 50, true);
            var handlers:Array<WebSocketHandler> = [];
            logs.add('Listening on port $port');

            while (true) {
                try {
                    if (swfs.count() > 0) {
                        logs.add('Sending change to clients (${handlers.length}) (${Math.ceil(swfs.first.length / 1024 / 1024 * 100) / 100} MB)');
                        
                        // Create chunks of messages
                        var bytes = swfs.first;
                        var max = 200 * 1024; // TODO: Why is that the ~maximum ??
                        var n = Math.ceil(bytes.length / max);
                        var parts = [];
                        for (i in 0...n) {
                            // OP    , ID        , Part,       Total,      Bytes
                            // 0xCACA, 0x00000000, 0x00000000, 0x00000001, ...
                            var len = (i == n - 1) ? bytes.length - (n - 1) * max : max;
                            var chunk = Bytes.alloc(2 + 4 + 4 + 4 + len);
                            chunk.setUInt16(0, 0xCACA);
                            chunk.setInt32(2, id);
                            chunk.setInt32(2 + 4, i);
                            chunk.setInt32(2 + 4 + 4, n);
                            chunk.blit(2 + 4 + 4 + 4, bytes, i * max, len);

                            parts.push(chunk);
                        }
                        
                        id++;

                        // Send to all connected clients
                        for (handler in handlers) {
                            //handler.sendString('TEST');
                            
                            // Send all individual chunks
                            for (i in 0...parts.length) {
                                var part = parts[i];
                                handler.sendBytes(part);
                            }
                        }

                        swfs.removeFirst();
                    }

                    var websocket = server.accept();
                    if (websocket != null) {
                        handlers.push(new WebSocketHandler(websocket));
                    }
                    
                    var toRemove = [];
                    for (handler in handlers) {
                        if (!handler.update()) {
                            toRemove.push(handler);
                        }
                    }
                    
                    while (toRemove.length > 0)
                        handlers.remove(toRemove.pop());
                        
                    Sys.sleep(0.1);
                } catch (e:Dynamic) {
                    logs.add('Error: $e');
                    //logs.add(CallStack.exceptionStack());
                }
            }
        }

        log('Server', 'Starting server thread', 0);
        executor.submit(startServer);

        addEventListener(Event.ENTER_FRAME, function(_) {
            if (logs.count() > 0) {
                log('Server', logs.first, 0);
                logs.removeFirst();
            }
        });

        // Start CLI
        var cli = new CLI();
        new mcli.Dispatch(Sys.args()).dispatch(cli);
        #end
	}
}