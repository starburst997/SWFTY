package;

import haxe.io.Bytes;

import swfty.exporter.Exporter;
import swfty.Structure;

import openfl.swfty.exporter.FontExporter;

import file.save.FileSave;

import hx.concurrent.executor.Executor;
import hx.files.*;
import hx.files.watcher.*;

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

	public function runDefault(?path:String) {
        this.path = path;

		if(path == null) {
            // Look for swfty.json
            var bytes = File.of(getFile('swfty.json')).readAsBytes();
            if (bytes != null) {
                loadConfig(bytes);
            } else {
                trace('Please specify a folder to watch or a .SWF to convert or have a swfty.json file!');
                Sys.exit(0);
            }
        } else {
            
            var p = Path.of(path);
            if (p.filenameExt.toLowerCase() == 'swf') {
                // Convert single SWF
                // TODO: Clean this up
                trace('Converting: ${p.toString()}...');
                FontExporter.path = getDir(this.fontPath != null ? this.fontPath : FontExporter.path);
                processSWF(getFile(path), exporter -> {
                    var zip = exporter.getSwfty();
                    var output = this.output == null ? getFile(p.parent.join(p.filenameStem).toString() + '.swfty') : getDir(this.output);
                    if (Path.of(output).isDirectory()) {
                        output += Path.of(output).join(p.filenameStem + '.swfty').toString();
                    }

                    trace('Saving: $output...');
                    FileSave.writeBytes(zip, output);
                    
                    trace('Done!');
                    Sys.exit(0);
                }, error -> {
                    trace('Error', error);
                    Sys.exit(0);
                });
            } else {
                // Look for a swfty.json in folder
                var bytes = File.of(p.join('swfty.json')).readAsBytes();
                if (bytes != null) {
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

        if (config.watch == null) config.watch = true;
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

        trace('Font path:', FontExporter.path);

        return config;
    }

    function loadConfig(bytes:Bytes) {
        try {
            if (bytes == null) throw 'no file';
            var config:Config = getConfig(haxe.Json.parse(bytes.toString()));

            processConfig(config);
        } catch(e:Dynamic) {
            trace('Error!!!', e);
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
            processSWF(path.toString(), exporter -> {
                var zip = exporter.getSwfty();
                
                var output = Path.of(getDir(config.outputFolder)).join(path.filenameStem + '.swfty').toString();

                // Makes sure dir exists
                Dir.of(Path.of(output).parent).create();

                trace('Saving: $output...');
                FileSave.writeBytes(zip, output);
                
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

            // Start socket server to send new bytes whenever a swfty gets compiled


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
                            trace('File modified: $file');
                            
                            timer.stop();
                            timer = null;

                            convertSWF(file.path);
                        }, 100);
                    case _ : 
                }
            });

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
            trace('Loading', path);

            var bytes = File.of(path).readAsBytes();
            if (bytes == null) throw 'File doesn\'t exists at $path';

            trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();
			Exporter.create(bytes, path, function(exporter) {
                trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
                onComplete(exporter);
            }, onError);
        } catch(e:Dynamic) {
            trace('Error!!!', e);
            onError(e);
        }
	}
}
#end

class Main extends Sprite {

	public function new() {	
		super();

        #if sys
        new mcli.Dispatch(Sys.args()).dispatch(new CLI());
        #end
	}
}