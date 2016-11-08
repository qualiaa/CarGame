package;

import flixel.math.FlxPoint;

@:forward(x,y)
abstract Point(FlxPoint) from FlxPoint to FlxPoint
{
    public inline function new(p : FlxPoint) {
        this = p;
    }

    public static inline function fromXY(x:Float,y:Float): Point {
        return new Point(FlxPoint.get(x,y));
    }

    public inline function magnitude() : Float{
        return Math.sqrt(magnitudeSquared());
    }

    public inline function magnitudeSquared() : Float {
        return this.x*this.x + this.y*this.y;
    }

    public function unit() : Point {
        var p = new Point(this);
        return p/p.magnitude();
    }

    public function normal(): Point {
        return FlxPoint.get(-this.y,this.x);
    }

    public function dot(p : FlxPoint) : Float {
        return this.x * p.x + this.y * p.y;
    }

    public function cross(p : FlxPoint) : Float {
        var pp = new Point(p);
        return pp.dot(normal());
    }

    public function rotate(angle: Float) : Point
    {
        var toRad = Math.PI / 180;
        angle *= toRad;

        return FlxPoint.get(this.x * Math.cos(angle) - this.y * Math.sin(angle),
                		    this.y * Math.cos(angle) + this.x * Math.sin(angle));
    }

    public function rotateAbout(p : Point, angle : Float) : Point
    {
        var ans  = new Point(this) - p;
        ans = ans.rotate(angle);
        return ans + p;
    }

    public function getAngle(p : FlxPoint) : Float
    {
        var radToDeg = 180 / Math.PI;
        return radToDeg * Math.atan2(cross(p), dot(p));
    }

    public function project (p: Point) : Float
    {
        return dot(p.unit());
    }

    public function fromFrame(f : Frame) : Point
    {
        return f.x * this.x + f.y * this.y;
    }

    public function toFrame(f : Frame) : Point
    {
        return Point.fromXY(dot(f.y.normal()),dot(f.x.normal()));
    }

    @:to(String)
    public inline function toString() : String
    {
        return "(" + this.x + ", " + this.y + ")";
    }

    @:op(-A)
    public inline function negate() : Point
    {
        return FlxPoint.get(-this.x,-this.y);
    }

    @:op(A + B)
    public inline function add_p(rhs:FlxPoint) : Point {
        return FlxPoint.get(this.x + rhs.x, this.y + rhs.y);
    }
    @:commutative
    @:op(A + B)
    public inline function add_f(rhs:Float) : Point {
        return FlxPoint.get(this.x + rhs, this.y + rhs);
    }
    @:commutative
    @:op(A + B)
    public inline function add_i(rhs:Int) : Point {
        return FlxPoint.get(this.x + rhs, this.y + rhs);
    }

    @:op(A - B)
    public inline function sub_p(rhs:FlxPoint) : Point {
        return FlxPoint.get(this.x - rhs.x, this.y - rhs.y);
    }
    @:op(A - B)
    public inline function sub_i(rhs:Int) : Point {
        return FlxPoint.get(this.x - rhs, this.y - rhs);
    }
    @:op(A - B)
    public inline function sub_f(rhs:Float) : Point {
        return FlxPoint.get(this.x - rhs, this.y - rhs);
    }

    @:commutative
    @:op(A * B)
    public inline function mul_i(rhs:Int) : Point {
        return FlxPoint.get(this.x * rhs, this.y * rhs);
    }
    @:commutative
    @:op(A * B)
    public inline function mul_f(rhs:Float) : Point {
        return FlxPoint.get(this.x * rhs, this.y * rhs);
    }

    @:op(A / B)
    public inline function div_i(rhs:Int) : Point {
        return FlxPoint.get(this.x / rhs, this.y / rhs);
    }
    @:op(A / B)
    public inline function div_f(rhs:Float) : Point {
        return FlxPoint.get(this.x / rhs, this.y / rhs);
    }

    @:op(A += B)
    public inline function asadd_p(rhs:FlxPoint) : Point {
        this.x += rhs.x;
        this.y += rhs.y;
        return this;
    }
    @:op(A += B)
    public inline function asadd_f(rhs:Float) : Point {
        this.x += rhs;
        this.y += rhs;
        return this;
    }
    @:op(A += B)
    public inline function asadd_i(rhs:Int) : Point {
        this.x += rhs;
        this.y += rhs;
        return this;
    }

    @:op(A -= B)
    public inline function assub_p(rhs:FlxPoint) : Point {
        this.x -= rhs.x;
        this.y -= rhs.y;
        return this;
    }
    @:op(A -= B)
    public inline function assub_i(rhs:Int) : Point {
        this.x -= rhs;
        this.y -= rhs;
        return this;
    }
    @:op(A -= B)
    public inline function assub_f(rhs:Float) : Point {
        this.x -= rhs;
        this.y -= rhs;
        return this;
    }
    @:op(A *= B)
    public inline function asmul_i(rhs:Int) : Point {
        this.x *= rhs;
        this.y *= rhs;
        return this;
    }
    @:op(A *= B)
    public inline function asmul_f(rhs:Float) : Point {
        this.x *= rhs;
        this.y *= rhs;
        return this;
    }
    @:op(A -= B)
    public inline function asdiv_i(rhs:Int) : Point {
        this.x /= rhs;
        this.y /= rhs;
        return this;
    }
    @:op(A -= B)
    public inline function asdiv_f(rhs:Float) : Point {
        this.x /= rhs;
        this.y /= rhs;
        return this;
    }

    @:op(A == B)
    public inline function cmp(rhs:FlxPoint) : Bool {
        return this.x == rhs.x && this.y == rhs.y;
    }

    @:op(A != B)
    public inline function ncmp(rhs:FlxPoint) : Bool {
        return !(this == rhs);
    }

    public static var zero(default, never)  = Point.fromXY(0,0);
    public static var axisX(default, never) = Point.fromXY(1,0);
    public static var axisY(default, never) = Point.fromXY(0,1);
    public static var positiveInfinity(default, never) =
        Point.fromXY(Math.POSITIVE_INFINITY,Math.POSITIVE_INFINITY);
    public static var negativeInfinity(default, never) =
        Point.fromXY(Math.NEGATIVE_INFINITY,Math.NEGATIVE_INFINITY);
}
