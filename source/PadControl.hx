package;

import flixel.input.gamepad.FlxGamepad;

class PadControl implements Control
{
    var pad_ : FlxGamepad;
    var lastSteerAmount_ = 0.0;

    static inline var steerThreshold = 0.1;
    static inline var analogThreshold = 0.5;

    public function new(pad :FlxGamepad)
    {
        pad_ = pad;
        id = pad_.id;
        ready = function()
            return pad_.justPressed.START
                || pad_.justPressed.A;

        back = function()
            return pad_.justPressed.BACK
                || pad_.justPressed.B;

        quit = back;
        unready = back;

        pause = function()
            return pad_.justPressed.START;

        switchColor = function() {
            var val = pad_.analog.value.LEFT_STICK_X;
            if (Math.abs(val) > analogThreshold) {
                if (val < 0) {
                    return LEFT;
                }
                else {
                    return RIGHT;
                }
            }
            else {
                return FORWARD;
            }
        }

        steer = function() {
            steerAmount = pad_.analog.value.LEFT_STICK_X;
            if (Math.abs(steerAmount - lastSteerAmount_) > steerThreshold) {
                lastSteerAmount_ = steerAmount;
                return true;
            }
            return false;
        }

        accelerate = function() {
            accelerateAmount = 1.0;
            return pad_.pressed.A;
        }

        brake = function() {
            return pad_.pressed.B;
        }
    }
    public var id(default,null) : Int;
    public var back             : Void -> Bool;
    public var ready            : Void -> Bool;
    public var unready          : Void -> Bool;
    public var pause            : Void -> Bool;
    public var quit             : Void -> Bool;
    public var switchColor      : Void -> Direction;
    public var steer            : Void -> Bool;
    public var accelerate       : Void -> Bool;
    public var brake            : Void -> Bool;
    public var steerAmount     (default,null) = 0.0;
    public var accelerateAmount(default,null) = 0.0;
}
