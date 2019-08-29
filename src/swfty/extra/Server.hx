package swfty.extra;

import haxe.net.WebSocket;
import haxe.macro.Compiler;
import haxe.ds.IntMap;
import haxe.io.Bytes;

#if !neko
import hx.concurrent.executor.*;
#end

class Server {

    // TODO: No way to "stop" it right now, I guess we could keep it in static var
    //       Also was done in a hurry (not super well done...), but hey it works!
    public static function run(manager:Manager) {
        #if !neko
        var retry = false;
        
        // This should be in your DEV code only
        // Start server
        var executor = Executor.create(1);
        var messages = new IntMap<{
            id: Int,
            total: Int,
            start: Float,
            time: Float,
            chunks: Array<{
                part: Int,
                bytes: Bytes
            }>
        }>();
        
        var startClient = function f():Void {

            // TODO: Get rid of message if it been over X sec

            var ip = if (Compiler.getDefine('server_ip') != null) {
                Compiler.getDefine('server_ip');
            } else {
                '192.168.0.193';
            }

            var stop = false;
            var ws = WebSocket.create('ws://$ip:49463/', [], false);
            ws.onopen = function() {
                trace('open!');

                // Try again
                for (message in messages) {
                    var parts = [for (i in 0...message.total) i];
                    for (chunk in message.chunks) {
                        parts.remove(chunk.part);
                    }

                    var bytes = Bytes.alloc(parts.length * 4 + 2 + 4);
                    bytes.setUInt16(0, 0xDEDE);
                    bytes.setInt32(2, message.id);
                    for (i in 0...parts.length) {
                        var part = parts[i];
                        bytes.setInt32(2 + 4 + i * 4, part);
                    }

                    ws.sendBytes(bytes);
                }
            };
            ws.onclose = function() {
                trace('close!');
                stop = true;

                #if html5
                retry = true;
                #end
            };
            ws.onerror = function(e) {
                //trace('close!', e);
                //ws.close();
                //stop = true;
            };
            /*ws.onmessageString = function(message) {
                trace('message from server!' + (message.length > 200 ? message.substr(0, 200) + '...' : message));
                trace('message.length=' + message.length);
            };*/
            ws.onmessageBytes = function(bytes) {
                //trace('message bytes from server!', bytes.length);

                // Verify magic number
                if (bytes.getUInt16(0) == 0xCACA) {
                    var id = bytes.getInt32(2);
                    var part = bytes.getInt32(2 + 4);
                    var total = bytes.getInt32(2 + 4 + 4);

                    if (!messages.exists(id)) {
                        trace('Received new message', id);
                        messages.set(id, {
                            id: id,
                            start: Date.now().getTime(),
                            time: Date.now().getTime(),
                            total: total,
                            chunks: []
                        });
                    }

                    var message = messages.get(id);
                    message.time = Date.now().getTime();

                    // Skip duplicate
                    for (chunk in message.chunks) {
                        if (chunk.part == part) return;
                    }

                    message.chunks.push({
                        part: part,
                        bytes: bytes
                    });

                    //trace(id, part, message.chunks.length, total);
                    if (message.chunks.length == total) {
                        trace('Received all message (${Math.ceil((Date.now().getTime() - message.start) / 1000 * 100) / 100} sec)');

                        // Calculate size and read name<
                        var len = 0;
                        var name = '';
                        for (chunk in message.chunks) {
                            len += chunk.bytes.length - (2 + 4 + 4 + 4);

                            if (chunk.part == 0) {
                                var l = chunk.bytes.getInt32(2 + 4 + 4 + 4);
                                len -= l + 4;
                                name = chunk.bytes.getString(2 + 4 + 4 + 4 + 4, l);
                            }
                        }

                        // Create SWFTY bytes back
                        var n = 0;
                        var swfty = Bytes.alloc(len);
                        for (chunk in message.chunks.sortf(function(chunk) return chunk.part)) {
                            var skip = 2 + 4 + 4 + 4 + (chunk.part == 0 ? 4 + chunk.bytes.getInt32(2 + 4 + 4 + 4) : 0);

                            swfty.blit(n, chunk.bytes, skip, chunk.bytes.length - skip);
                            n += chunk.bytes.length - skip;
                        }

                        trace('Got SWFTY!', name, swfty.length);

                        manager.setCache(name, swfty);

                        for (layer in manager.layers) {
                            if (layer.id == name) {
                                trace('Found a layer!');
                                layer.loadBytes(swfty);
                            }
                        }
                        
                        messages.remove(id);
                    }
                }
            };

            #if sys
            while (!stop) {
                ws.process();
                Sys.sleep(0.01);
            }
            #end
        };

        executor.submit(startClient);
        executor.onResult = function(_) {
            #if sys
            trace('ON RESULT!!! Restarting');
            haxe.Timer.delay(function() {
                executor.submit(startClient);
            }, 500);
            #end
        };

        manager.addRender(function() {
            if (retry) {
                retry = false;
                haxe.Timer.delay(function() {
                    executor.submit(startClient);
                }, 500);
            }

            for (message in messages) {
                if (Date.now().getTime() - message.time > 60 * 1000) {
                    trace('Removed', message.id);
                    messages.remove(message.id);
                }
            }
        });
        #end
    }
}