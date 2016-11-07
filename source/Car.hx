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
    public static var carMass = 1;

    static var wheelOffsets : Array<Point> = [
        FlxPoint.get(-9,-6.5),
        FlxPoint.get(-9, 6.5),
        FlxPoint.get( 6,-6.5),
        FlxPoint.get( 6, 6.5),
    ];

    static var frontWindscreenShape = new Rectangle(15,2,3,9);
    static var backWindscreenShape  = new Rectangle(2,2,2,9);

    static var wheelBase : Float = wheelOffsets[2].x - wheelOffsets[0].x;

    static var maxWheelRotation = 30;
    static var maxSpeed = 2;

    public var carColor(default,null) : Color = Red;
    public var center(get,never) : Point;

    public var angularFrequency(get,never) : Float;


    public static inline var pixelPerMeter = carWidth/4.5;
    public static inline var gravity = 9.8 * pixelPerMeter / 60;
    public static var tractionForce = 0.3;
    public static var dragCoefficient(default,never) = 0.005;
    public static inline var frictionCoefficientMud = 0.57;
    public static inline var frictionCoefficientIce = 0.57;
    public static inline var frictionCoefficientRoad = 1.0;
    public static inline var brakeCoefficient = 0.01;


    var steerAngle_ = 0.0;
    var speed_      = 0.0;
    var velocity_   = Point.zero;
    var direction_  = Point.axisX;

    var forces_ : Array<Point> = [];
    var wheels_ : Array<Wheel> = [];
    var player_ : Player;
    var debugLayer_ : FlxSprite;

    var position (get,set): Point;

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

        debugLayer_ = new FlxSprite();
        debugLayer_.makeGraphic(640,480,FlxColor.fromInt(0x00));
        FlxG.state.add(debugLayer_);
    }

    public override function update(dt: Float)
    {
        debugLayer_.fill(FlxColor.TRANSPARENT);

        resolveForces();
        var w = angularFrequency;
        if (w != 0.0) {
            angle += w;
            direction_ = direction_.rotate(w);
            velocity_ = velocity_.rotate(w);
        }

        position += velocity_;

        positionWheels();

        if (FlxG.debugger.visible) {
            drawDebugInformation();
        }
    }

    private function accelerate() : Void
    {
        addForce(direction_ * tractionForce);
    }

    private function brake() : Void
    {
        addForce(-velocity_ * brakeCoefficient);
    }

    public function addForce(f : Point) : Void
    {
        forces_.push(f);
    }

    private function resolveForces() : Void
    {
        addForce(dragForce());
        if (velocity_.magnitude() > 0) {
            addForce(frictionForce());
        }

        for (force in forces_) {
            velocity_ += force / carMass;
        }
        forces_ = [];
    }

    private function positionWheels() : Void
    {
        var midpoint = Point.fromXY(carWidth/2,carHeight/2);
        for (i in 0...wheels_.length) {
            var wheel = wheels_[i];
            wheel.angle = angle;
            if (wheel.rotates) {
                wheel.angle += steerAngle_;
            }
            var pos = wheelOffsets[i].rotate(angle);
            wheel.center = center + pos;
            wheel.position = wheel.center - Point.fromXY(1.5,1);
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

    public function onNotify(e: Event, s: Subject) {
        //trace("Event received");
        if (s == player_) {
            switch(e) {
                case CONTROL_STEER:
                    //trace("Steer event received");
                    steerAngle_ = player_.control.steerAmount * maxWheelRotation;
                case CONTROL_ACCELERATE:
                    accelerate();
                case CONTROL_BRAKE:
                    brake();
                default:
            }
        }
    }

    public function get_position() : Point
    {
        return FlxPoint.get(x,y);
    }
    public function set_position(a : FlxPoint) : Point
    {
        x = a.x;
        y = a.y;
        return a;
    }
    public function get_angularFrequency() : Float
    {
        var w = 0.0;
        if (steerAngle_ != 0) {
            // car will follow circular path
            var radius = (wheelBase / Math.sin(Math.PI*steerAngle_/180));
            w = (velocity_.magnitude()/radius)*(180/Math.PI);
        }
        trace(w);
        return w;
    }
    public function get_center() : Point
    {
        return position + Point.fromXY(carWidth/2,carHeight/2);
    }

    private function drawDebugInformation() {
        var w = angularFrequency;
        var d = (steerAngle_ < 0) ? -1 : 1;

        // Cross at (0,0)
        /*
        debugLayer_.drawLine(position.x-2,position.y-2,
                             position.x+2,position.y+2,
                             { thickness: 1, color: FlxColor.BLACK});
        debugLayer_.drawLine(position.x+2,position.y-2,
                             position.x-2,position.y+2,
                             { thickness: 1, color: FlxColor.BLACK});
         */

        // Direction Vector
        debugLayer_.drawLine(center.x,center.y,
                             center.x+direction_.x*10,
                             center.y+direction_.y*10,
                             {thickness: 1, color: FlxColor.RED});
        // Circle at center
        debugLayer_.drawCircle(center.x,center.y,2,FlxColor.BLUE);

        // Wheel lines
        var frontWheel = (steerAngle_ < 0) ? wheels_[2] : wheels_[3];
        var backWheel  = (steerAngle_ < 0) ? wheels_[0] : wheels_[1];
        var backNormal = direction_.normal() * d;
        var frontNormal = Point.axisX.rotate(frontWheel.angle).normal() * d;
        line(backWheel.center, backWheel.center+backNormal*10,FlxColor.WHITE);
        line(frontWheel.center, frontWheel.center+frontNormal*10,FlxColor.WHITE);

        // Velocity lines
        var alongMag  = velocity_.magnitude() * Math.cos(Math.PI*w/180);
        var acrossMag = velocity_.magnitude() * Math.sin(Math.PI*w/180);
        line(center, center + direction_          * alongMag  * 100);
        line(center, center + direction_.normal() * acrossMag * 100, FlxColor.RED);


    }

    private function frictionCoefficient() : Float
    {
        return dragCoefficient*30;
    }

    private function dragForce() : Point
    {
        return -velocity_ * velocity_.magnitude() * dragCoefficient   ;
    }

    private function frictionForce() : Point
    {
        return - velocity_.unit() * frictionCoefficient();
    }

    private function line(p1:Point,p2:Point,
                          c:FlxColor = FlxColor.BLACK,t :Int = 1) : Void
    {
        debugLayer_.drawLine(p1.x,p1.y,p2.x,p2.y,{thickness:t,color:c});

    }
}

class Wheel extends FlxSprite
{
    public static inline var wheelColor : UInt = 0xff33321e;
    public static inline var wheelWidth = 3;
    public static inline var wheelHeight = 2;
    public static var wheelBmp = new BitmapData(wheelWidth,wheelHeight, true, wheelColor);

    public var rotates(default,null) = false;

    public var center : Point;
    public var position (get,set): Point;

    public function new(rotates: Bool, ?x : Float, ?y: Float)
    {
        //super();
        super(x, y);
        loadGraphic(wheelBmp);
        this.rotates = rotates;
    }

    public function get_position() : Point
    {
        return FlxPoint.get(x,y);
    }
    public function set_position(a : FlxPoint) : Point
    {
        x = a.x;
        y = a.y;
        return a;
    }
}
