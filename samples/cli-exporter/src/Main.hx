package;

import haxe.io.Bytes;

import swfty.exporter.Exporter;
import swfty.Structure;

import openfl.swfty.exporter.FontExporter;

import file.save.FileSave;

import hx.concurrent.executor.*;
import hx.files.*;
import hx.files.watcher.*;
import hx.concurrent.event.*;
import hx.concurrent.collection.*;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Assets;

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

    function error(text:String) {
        Console.log('<b>* Error: <#FF0000>$text</></>');
    }

    function log(text:String, ?info:String, ?depth = 1) {
        Console.log('<b>${[for (i in 0...Std.int(Math.max(depth - 1, 0))) '  '].join('')}${depth == 0 ? '' : '- '}$text</>${info == null ? '' : '<b>:</> <i>$info</>'}');
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

                // Makes sure dir exists
                Dir.of(Path.of(output).parent).create();

                log('Saving', '$output', 2);
                FileSave.writeBytes(zip, output);

                Main.swfs.add('LOL!');

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
			Exporter.create(bytes, path, function(exporter) {
                log('Parsed SWF', '${haxe.Timer.stamp() - timer} sec', 2);
                onComplete(exporter);
            }, onError);
        } catch(e:Dynamic) {
            error(e);
            onError(e);
        }
	}
}
#end

class Echo extends hxnet.protocols.WebSocket
{
    public function new() {
        super();
    }

	override private function recvText(line:String)
	{
        trace('HEY!', line);
	}

}

class Main extends Sprite {

    public static var swfs:SynchronizedArray<String> = new SynchronizedArray();

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
        Console.log('https://github.com/starburst997/SWFTY');
        Console.log('');

        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            // Do nothing!
        };

        #if sys
        // Start server
        var executor = Executor.create(1);
        
        var startServer = function():Void {
            var server = new hxnet.tcp.Server(new hxnet.base.Factory(Echo), 9971, 'localhost');

		    server.listen();
            while (true) {
                server.update();

                if (swfs.count() > 0) {
                    trace('FOUND SOMETHING', swfs.first);
                    
                    @:privateAccess for (client in server.clients.keys()) {
                        // Bytes.ofString(swfs.first)
                        trace(client);
                        cast(client.custom, Echo).sendText('Yay!');
                    };

                    swfs.removeFirst();
                } 

                Sys.sleep(0.01); // wait for 1 ms
            }
        }

        executor.submit(startServer);

        // Start CLI
        var cli = new CLI();
        new mcli.Dispatch(Sys.args()).dispatch(cli);
        #end
	}
}