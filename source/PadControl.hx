package;

import flixel.input.gamepad.FlxGamepad;

class PadControl implements Control
{
    private var pad_ : FlxGamepad;

    private static inline var analogThreshold = 0.5;

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
    }
    public var id(default,null) : Int;
    public var back : Void -> Bool;
    public var ready : Void -> Bool;
    public var unready : Void -> Bool;
    public var pause : Void -> Bool;
    public var quit : Void -> Bool;
    public var switchColor : Void -> Direction;
}
