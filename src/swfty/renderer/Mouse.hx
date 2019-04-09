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

    var queueLeft:Array<ButtonState> = [];
    var queueMiddle:Array<ButtonState> = [];
    var queueRight:Array<ButtonState> = [];

    var disableReset = false;

    public function new(disableReset = false) {
        this.disableReset = disableReset;
    }

    inline function set_left(state:ButtonState) {
        if (leftChanged) {
            trace('!!!!!!!!!!!!!!! QUEUE LEFT');
            queueLeft.push(state);
        } else {
            left = state;
            leftChanged = true;
        }
        return state;
    }

    inline function set_middle(state:ButtonState) {
        if (middleChanged) {
            queueMiddle.push(state);
        } else {
            middle = state;
            middleChanged = true;
        }
        return state;
    }

    inline function set_right(state:ButtonState) {
        if (rightChanged) {
            queueRight.push(state);
        } else {
            right = state;
            rightChanged = true;
        }
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

        // TODO: Find a way to set the getter without calling the setter?
        leftChanged = false;
        rightChanged = false;
        middleChanged = false;

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

        if (queueLeft.length > 0) left = queueLeft.shift();
        if (queueMiddle.length > 0) middle = queueMiddle.shift();
        if (queueRight.length > 0) right = queueRight.shift();
    }
}