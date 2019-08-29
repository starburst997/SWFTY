package;

import haxe.Json;
import haxe.io.Bytes;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

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
		Path of the abstract directory
        @alias a
	**/
	public var abstractPath:String = null;

    /**
		Watch for file changes (only works on folder)
        @alias w
	**/
	public var watch:Bool = false;

    /**
		Recreate every SWF in the folder
        @alias c
	**/
	public var recreate:Bool = false;

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
                processSWF(getFile(path), null, exporter -> {
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
        config = Exporter.getConfig(config);

        // CLI arguments overwrite the config
        if (config.watch == null) config.watch = this.watch;
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
        // Creating quality enum
        var quality = new StringMap<String>();
        quality.set('normal', Path.of(config.outputFolder).toStringWithTrailingSeparator());

        for (q in config.quality) {
            quality.set(q.name, Path.of(q.outputFolder).toStringWithTrailingSeparator());
        }

        function convertSWF(path:Path, ?onComplete:Void->Void) {
            function onError(e) {
                error(e);
            }

            log('Converting', path.toString());
            processSWF(config, path.toString(), config.watchFolder, exporter -> {
                log('Exporting', path.toString(), 2);

                var original = null;
                var first = null;

                Exporter.addLog('Export: ${path.toString()}');

                var die = false;

                // Save all quality
                for (quality in exporter.getQualities()) {

                    var w = quality.maxDimension.width;
                    var h = quality.maxDimension.height;

                    if (first == null) {
                        var name = '${exporter.name}.swf';
                        for (file in config.files) {
                            if (file.name == name) {
                                if (file.maxDimension != null) {
                                    w = file.maxDimension.width;
                                    h = file.maxDimension.height;
                                }
                                break;
                            }
                        }
                    }

                    if (first != null) {
                        var dimension = exporter.getMaxDimension(first.maxWidth, first.maxHeight, first.width, first.height, w, h);
                        w = dimension.width;
                        h = dimension.height;
                    }

                    var zip = exporter.getSwfty(false, true, w, h, quality.scale, first != null);
                    var output = Path.of(getDir(quality.outputFolder)).join(exporter.name + '.swfty').toString();

                    var tilemap = exporter.getTilemap();
                    log('Size', '${Math.ceil(zip.length / 1024 / 1024 * 100) / 100} MB', 2);
                    log('Tilemap', '${tilemap.bitmapData.width}x${tilemap.bitmapData.height}', 2);

                    if (tilemap.bitmapData.width < 4 || tilemap.bitmapData.height < 4) {
                        die = true;
                        break;
                    }

                    if (first == null) {
                        first = {
                            maxWidth: quality.maxDimension.width,
                            maxHeight: quality.maxDimension.height,
                            width: tilemap.bitmapData.width,
                            height: tilemap.bitmapData.height
                        };
                    }

                    // Makes sure dir exists
                    Dir.of(Path.of(output).parent).create();

                    log('Saving', '$output', 2);
                    FileSave.writeBytes(zip, output);

                    if (quality.scale == 1.0) original = zip;
                }

                if (die) {
                    error('Bad file, skipping...');
                
                    if (onComplete != null) onComplete();
                    return;
                }

                // Save abstract
                var abstractPath = Path.of(getDir(config.abstractFolder)).join(exporter.name + '.hx').toString();

                // Makes sure dir exists
                Dir.of(Path.of(abstractPath).parent).create();

                // Grab template files
                inline function getTemplate(name:String) {
                    if (config.templateFolder.empty()) return '';
                    var templatePath = Path.of(getDir(config.templateFolder)).join(name + '.mustache');
                    return templatePath.toFile().readAsString('');
                }

                log('Saving', '$abstractPath', 2);
                FileSave.writeBytes(Bytes.ofString(exporter.getAbstracts(getTemplate('Layer.hx'))), abstractPath);

                var rootPath = Path.of(getDir(config.abstractFolder)).join('SWFTY.hx').toString();
                log('Saving', '$rootPath', 2);

                // Get list of all swfty files
                var files = [];
                #if (filesystem_support || macro)
                for (file in Dir.of(getDir(quality.get('normal'))).findFiles("**/*.swfty")) {
                    var name = file.path.filenameStem; 
                    files.push({
                        path: file.path.toString(),
                        name: name,
                        capitalizedName: name.capitalize()
                    });
                }
                #end

                FileSave.writeBytes(Bytes.ofString(exporter.getRootAbstract(quality, files, getTemplate('SWFTY.hx'))), rootPath);

                // Craft message to be sent to server
                if (original != null) {
                    var idBytes = Bytes.ofString(exporter.name);
                    var messageBytes = Bytes.alloc(idBytes.length + 4 + original.length);
                    messageBytes.setInt32(0, idBytes.length);
                    messageBytes.blit(4, idBytes, 0, idBytes.length);
                    messageBytes.blit(idBytes.length + 4, original, 0, original.length);
                    Main.swfs.add(messageBytes);
                }

                log('Done!');
                
                if (onComplete != null) onComplete();
            }, onError);
        }

        if (config.watch) {
            Exporter.logs = 'SWFTY Reports:';
            
            // Look for all SWF in folder, convert any that don't have a "swfty" counter part
            var swfs = listFiles(Dir.of(getDir(config.watchFolder)));
            var random = [];
            var i = 0;
            for (swf in swfs) {
                random.push(i++);
            }

            var newSWFs = [];
            for (swf in swfs) {
                var i = Std.int(Math.random() * random.length);
                var r = random[Std.int(Math.random() * random.length)];
                random.splice(i, 1);

                newSWFs.push(swfs[r]);
            }
            swfs = newSWFs;

            var swftys = [for (file in listFiles(Dir.of(getDir(config.outputFolder)), 'swfty')) file.path.filenameStem => !recreate];

            var quality = new StringMap<StringMap<Bool>>();
            for (q in config.quality) {
                quality.set(q.name, [for (file in listFiles(Dir.of(getDir(q.outputFolder)), 'swfty')) file.path.filenameStem => !recreate]);
            }

            var total = 0;
            var todo = 0;
            for (swf in swfs) {
                // Check quality SWFTY missing
                var qualityExists = true;
                for (q in config.quality) {
                    if (!swftys.exists(swf.path.filenameStem) || !swftys.get(swf.path.filenameStem)) {
                        qualityExists = false;
                        break;
                    }
                }

                if (!qualityExists || !swftys.exists(swf.path.filenameStem) || !swftys.get(swf.path.filenameStem)) {
                    // Convert SWF
                    todo++;
                    convertSWF(swf.path, () -> {
                        if (++total == todo) {
                            // Save report
                            var reportPath = Path.of(getDir('.')).join('swfty-report.log').toString();
                            log('Saving log', '$reportPath', 2);
                            FileSave.writeBytes(Bytes.ofString(Exporter.logs), reportPath);                            
                        }
                    });
                    swftys.set(swf.path.filenameStem, true);
                }
            }

            if (recreate) {
                Sys.exit(0);
            } else {
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
            }
        } else {
            // Process entire folder conveerting all SWF
            var swfs = listFiles(Dir.of(getDir(config.watchFolder)));
            for (swf in swfs) {
                convertSWF(swf.path);
            }
        }
    }

    function processSWF(?config:Config, path:String, folder:String, onComplete:Exporter->Void, onError:Dynamic->Void) {
		try {
            log('Loading', path, 2);

            var bytes = File.of(path).readAsBytes();
            if (bytes == null) throw 'File doesn\'t exists at $path';
            if (bytes.length < 50) throw 'File is pretty small, skipping at $path';

            log('Loaded', '${Math.ceil(bytes.length/1024)} KB', 2);

			var timer = haxe.Timer.stamp();

            Exporter.tempFolder = getDir('./temp');

            var id = path.substr(getDir(folder).length).replace('.swf', '');
			Exporter.create(bytes, config, id, function(exporter) {
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
    public static var parts = new IntMap<{
        id: Int,
        start: Float,
        time: Float,
        chunks: Array<Bytes>
    }>();

	static var _nextId = 0;
	var _id = _nextId++;
	var _websocket:WebSocket;

    public var isOpen = false;

    public var wait = 0.0001;
    public var size = 1 * 1024;

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

        isOpen = true;
    }

    function onerror(message:String):Void {
		//Main.logs.add('$_id:error: $message');
    }

    function onmessageString(message:String):Void {
		Main.logs.add('$_id:message: $message');
    }

    function onmessageBytes(message:Bytes):Void {
		//Main.logs.add('$_id:message bytes:' + message.length);
		
        if (message.getUInt16(0) == 0xDEDE) {
            var id = message.getInt32(2);
            if (parts.exists(id)) {
                Main.logs.add('Sending $id again');

                var ps = parts.get(id);
                for (i in 0...Std.int((message.length - 2 - 4) / 4)) {
                    if (_websocket.readyState != Open) {
                        //Console.log('break;');
                        break;
                    } 

                    var p = message.getInt32(i * 4 + 2 + 4);

                    ps.time = Date.now().getTime();
                    
                    var part = ps.chunks[p];
                    sendBytes(part);
                    Sys.sleep(wait);
                }

                Main.logs.add('Sent all! ${Std.int((message.length - 2 - 4) / 4)}');
            }
        }
    }

    public function sendBytes(message:Bytes) {
        if (_websocket.readyState == Open) _websocket.sendBytes(message);
    }

    public function sendString(message:String) {
        if (_websocket.readyState == Open) _websocket.sendString(message);
    }

    function onclose():Void {
		Main.logs.add('$_id:close');

        isOpen = false;
    }
}

class Main extends Sprite {

    // TODO: Let client specify those along with size?
    public static var wait = 0.0001;

    public static var id = Std.int(Math.random() * 10000000);
    public static var swfs:SynchronizedArray<Bytes> = new SynchronizedArray();
    public static var logs:SynchronizedArray<String> = new SynchronizedArray();

    public static function error(text:String) {
        Console.log('<b>* Error: <#CC0000>$text</></>');
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
        Console.log('<b><$color1>SWFTY</></> <i><b>(</></><i>0.4.0</><i><b>)</></> by <b><i>Jean-Denis Boivin</></>');
        Console.log('');
        Console.log('<u>https://github.com/starburst997/SWFTY</>');
        Console.log('');

        #if !debug
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            //Console.log('<b><#ffa500>WARNING:</></> $v');
        };
        #end

        #if sys
        // Start server
        // TODO: Instead of sending the bytes throught the socket, only tell the client, then load using a file server or something
        //       Still work pretty well from my test with iphone and fast enough, so not a priority... I don't want to add too much extra dependencies
        var executor = Executor.create(1);
        var startServer = function():Void {

            var port = 0xC137;
            var server = WebSocketServer.create('0.0.0.0', port, 10, true);
            var handlers:Array<WebSocketHandler> = [];
            logs.add('Listening on port $port');

            while (true) {
                try {
                    if (swfs.count() > 0) {
                        logs.add('Sending change to clients (${handlers.length}) (${Math.ceil(swfs.first.length / 1024 / 1024 * 100) / 100} MB)');
                        
                        // Create chunks of messages
                        var bytes = swfs.first;
                        var max = 1 * 1024 - (2 + 4 + 4 + 4); // TODO: Why is that the ~maximum ??
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

                        var p = {
                            id: id,
                            start: Date.now().getTime(), 
                            time: Date.now().getTime(),
                            chunks: parts
                        };
                        WebSocketHandler.parts.set(id, p); // TODO: Use hash of id + size instead
                        
                        // TODO: Auto-delete after 1 minute?

                        id++;

                        // Send to all connected clients
                        for (handler in handlers) {
                            //handler.sendString('TEST');
                            
                            var time1 = Date.now().getTime();

                            // Send all individual chunks
                            for (i in 0...parts.length) {
                                if (!handler.isOpen) {
                                    Console.log('break;');
                                    break;
                                }
                                
                                p.time = Date.now().getTime();

                                var part = parts[i];
                                handler.sendBytes(part);
                                Sys.sleep(wait);
                            }

                            //Console.log('Sent took: ${(Date.now().getTime() - time1) / 1000}');
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
                        
                    Sys.sleep(0.01);
                } catch (e:Dynamic) {
                    logs.add('Error: $e');
                    //logs.add(CallStack.exceptionStack());

                    // Prevent infinite errors
                    swfs.removeFirst();
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

            for (p in WebSocketHandler.parts) {
                if (Date.now().getTime() - p.time > 60 * 1000) {
                    //Console.log('Removed: ' + p.id);
                    WebSocketHandler.parts.remove(p.id);
                }
            }
        });

        // Fix trace statements
        Log.warn = function(str) {
            Console.log('<#CC000000>Error:</> $str');
        }

        // Start CLI
        var cli = new CLI();
        new mcli.Dispatch(Sys.args()).dispatch(cli);
        #end

        stage.frameRate = 0xFFFF;
	}
}