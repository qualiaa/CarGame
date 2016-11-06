package;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxRect;
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

class Car extends FlxSpriteGroup
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

    var wheels_ : Array<Wheel> = [];
    var body_ = new CarBody();
    var t_ = 0;

    public function new (?x:Float = 0, ?y:Float = 0) {
        super(x,y);

        for (i in 0...4) {
            var wheel = new Wheel(i);
            wheels_.push(wheel);
            add(wheel);
        }
        add(body_);
    }

    public override function update(dt: Float) {
        angle++;
        //x = 200+100*Math.sin(angle*Math.PI / 180);
    }
}

class CarBody extends FlxSprite
{
    public static inline var carWidth  = 24;
    public static inline var carHeight = 13;
    public static var frontWindscreenShape = new Rectangle(15,2,3,9);
    public static var backWindscreenShape = new Rectangle(2,2,2,9);

    public var carColor(default,null) : Color = Red;

    public function new()
    {
        super();
        var graphic =
            new BitmapData(carWidth,carHeight, true, Car.colorTable[carColor]);

        graphic.fillRect(frontWindscreenShape,Car.colorTable[Glass]);
        graphic.fillRect(backWindscreenShape,Car.colorTable[Glass]);
        loadGraphic(graphic);
    }
}

class Wheel extends FlxSprite
{
    public static inline var wheelColor : UInt = 0xff33321e;
    public static inline var wheelWidth = 3;
    public static inline var wheelHeight = 2;
    public static var wheelBmp = new BitmapData(wheelWidth,wheelHeight, true, wheelColor);
    
    public var rotated = true;
    public var lastAngle = 0.0;
    public var rotAngle = Math.PI/6;

    static var wheelPositionsCentre = [
        {x:-9, y: -7.5},
        {x:-9, y: 5.5},
        {x:6,  y: -7.5},
        {x:6,  y: 5.5},
    ];

    public function new(i : Int)
    {
        var p = wheelPositionsCentre[i];
        //super();
        super(p.x + CarBody.carWidth / 2, p.y + CarBody.carHeight / 2);
        loadGraphic(wheelBmp);
        origin.x = -p.x;
        origin.y = -p.y;
    }

    public override function update(dt : Float) :Void {
        angle = 0;
    }
    public override function draw() : Void {
        /*
        if (rotated && rotAngle != lastAngle)
        {
            var size = Math.ceil(Math.sqrt(wheelWidth  * wheelWidth +
                                 wheelHeight * wheelHeight));
            var graphic = new BitmapData(Std.int(size),Std.int(size),true,0);
            var transform = new Matrix();
            transform.translate(size/2,size/2);
            transform.rotate(rotAngle);
            lastAngle = rotAngle;
            graphic.draw(wheelBmp, transform);
            pixels = graphic;
        }
        else if (!rotated)
        {
            pixels = wheelBmp;
        }
        */

        super.draw();
    }
}
