package swfty.renderer;

enum ButtonState {
    Down;
    Up;
    Normal;
}

class Mouse {
    
    public var x:Float = 0.0;
    public var y:Float = 0.0;
    
    public var leftChanged:Bool = false;
    public var middleChanged:Bool = false;
    public var rightChanged:Bool = false;

    public var left(default, set):ButtonState = Normal;
    public var middle(default, set):ButtonState = Normal;
    public var right(default, set):ButtonState = Normal;

    var disableReset = false;

    public function new(disableReset = false) {
        this.disableReset = disableReset;
    }

    inline function set_left(state:ButtonState) {
        left = state;
        leftChanged = true;
        return state;
    }

    inline function set_middle(state:ButtonState) {
        middle = state;
        middleChanged = true;
        return state;
    }

    inline function set_right(state:ButtonState) {
        right = state;
        rightChanged = true;
        return state;
    }

    public inline function isLeftDown() {
        return switch(left) {
            case Down : true;
            case _    : false;
        }
    }

    public inline function isRightDown() {
        return switch(right) {
            case Down : true;
            case _    : false;
        }
    }

    public inline function reset(force = false) {
        if (!force && disableReset) return;

        switch(left) {
            case Up : left = Normal;
            case _  :
        }
        switch(middle) {
            case Up : middle = Normal;
            case _  :
        }
        switch(right) {
            case Up : right = Normal;
            case _  :
        }

        leftChanged = false;
        rightChanged = false;
        middleChanged = false;
    }
}