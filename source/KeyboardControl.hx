package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepad;

class KeyboardControl implements Control
{
    var lastSteerAmount_ = 0.0;

    public function new()
    {
        id = -1;
        ready = function()
            return
                FlxG.keys.justPressed.SPACE;

        back = function()
            return
                FlxG.keys.justPressed.ESCAPE;

        quit = back;
        unready = back;

        pause = function()
            return
                FlxG.keys.justPressed.ESCAPE;

        switchColor = function() {
            if (FlxG.keys.pressed.LEFT)       { return LEFT; }
            else if (FlxG.keys.pressed.RIGHT) { return RIGHT; }
            else return FORWARD;
        }

        steer = function() {
            if (FlxG.keys.pressed.LEFT)       { steerAmount = -1; }
            else if (FlxG.keys.pressed.RIGHT) { steerAmount = 1; }
            else { steerAmount = 0; };
            return true;
        }

        accelerate = function() {
            accelerateAmount = 1.0;
            return FlxG.keys.pressed.UP;
        }

        brake = function() {
            return FlxG.keys.pressed.SPACE;
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
