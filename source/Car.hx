package;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

enum Color {
    Red;
    Yellow;
    Orange;
    Pink;
    Black;
    White;
    Glass;
}

class Car extends FlxSprite implements Observer
{
    public static var colorTable(default,never) : Map<Color, UInt> = [
        Red    => 0xffea6666,
        Yellow => 0xfffef898,
        Orange => 0xfff4c37d,
        Pink   => 0xffe58ec5,
        Black  => 0xff5f5f5f,
        White  => 0xffffffff,
        Glass  => 0xff8cd8f4
    ];

    public static inline var carWidth  = 24;
    public static inline var carHeight = 13;
    static var frontWindscreenShape = new Rectangle(15,2,3,9);
    static var backWindscreenShape  = new Rectangle(2,2,2,9);

    static var wheelOffsets = [
        FlxPoint.get(-9,-7.5),
        FlxPoint.get(-9, 5.5),
        FlxPoint.get( 6,-7.5),
        FlxPoint.get( 6, 5.5),
    ];

    static var maxWheelRotation = 45;
    static var deltaAcceleration = 0.01;
    static var maxSpeed = 10;

    public var carColor(default,null) : Color = Red;


    var steerAngle_ = 30.0;
    var speed_      = 0.0;
    var direction_  = FlxPoint.get(1.0,0);

    var wheels_ : Array<Wheel> = [];
    var player_ : Player;


    public function new (p: Player, ?x:Float = 0, ?y:Float = 0)
    {
        super(x,y);

        player_ = p;

        var graphic =
            new BitmapData(carWidth,carHeight, true, Car.colorTable[p.color]);

        graphic.fillRect(frontWindscreenShape,Car.colorTable[Glass]);
        graphic.fillRect(backWindscreenShape,Car.colorTable[Glass]);
        loadGraphic(graphic);

        // Create wheels
        for (i in 0...4) {
            var rotates = true;
            if (i < 2) {
                rotates = false;
            }
            var wheel = new Wheel(rotates);
            wheels_.push(wheel);
            FlxG.state.add(wheel);
        }
        FlxG.state.add(this);
    }

    public override function update(dt: Float)
    {
        /*
           if steerAngle - 0.0 < circleRadius =
            deltaAngle =
        */
        x += speed_ * direction_.x;
        y += speed_ * direction_.y;
        positionWheels();
    }

    private function accelerate() : Void
    {
        speed_ += deltaAcceleration * player_.control.accelerateAmount;

        if (speed_ > maxSpeed) speed_ = maxSpeed;
    }

    public function onNotify(e: Event, s: Subject) {
        trace("Event received");
        if (s == player_) {
            switch(e) {
                case CONTROL_STEER:
                    trace("Steer event received");
                    steerAngle_ = player_.control.steerAmount * maxWheelRotation;
                case CONTROL_ACCELERATE:
                    accelerate();
                default:
            }
        }
    }

    private function positionWheels() : Void
    {
        var midpoint = FlxPoint.get(carWidth/2,carHeight/2);
        for (i in 0...wheels_.length) {
            var wheel = wheels_[i];
            wheel.angle = angle;
            if (wheel.rotates) {
                wheel.angle += steerAngle_;
            }
            var pos = wheelOffsets[i].rotate(FlxPoint.get(0,0), angle);
            wheel.x = x + pos.x + midpoint.x;
            wheel.y = y + pos.y + midpoint.y;
        }
    }

    public function destruct() : Void
    {
        for (wheel in wheels_) {
            FlxG.state.remove(wheel);
        }
        FlxG.state.remove(this);
        wheels_ = null;
        destroy();
    }
}

class Wheel extends FlxSprite
{
    public static inline var wheelColor : UInt = 0xff33321e;
    public static inline var wheelWidth = 3;
    public static inline var wheelHeight = 2;
    public static var wheelBmp = new BitmapData(wheelWidth,wheelHeight, true, wheelColor);

    public var rotates(default,null) = false;

    public function new(rotates: Bool, ?x : Float, ?y: Float)
    {
        //super();
        super(x, y);
        loadGraphic(wheelBmp);
        this.rotates = rotates;
    }
}
