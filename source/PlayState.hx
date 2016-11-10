package;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;
using Lambda;

class PlayState extends FlxState
{
    var track_ : Track;

    var players_ : Array<Player>;
    var cars_ : Array<Car> = [];
    var debugLayer_ : FlxSprite;

    public function new(players : Array<Player>) {
        super();
        players_ = players;
    }

	override public function create():Void
	{
		super.create();

        debugLayer_ = new FlxSprite();
        debugLayer_.makeGraphic(800,600,FlxColor.TRANSPARENT);
        track_ = new Track();
        add(track_);

        var i : Int = 0;
        for (player in players_) {
            var x = 398 + 41*Std.int(i / 2);
            var y = 350 + 24*(i % 2);
            ++i;
            var car = new Car(player,x,y, debugLayer_);
            player.register(car);
            car.angle = 180;
            cars_.push(car);
        }

        for (j in i...6) {
            var x = 398 + 41*Std.int(j / 2);
            var y = 350 + 24*(j % 2);
            var car = new Car(null, x,y, debugLayer_);
            add(car);
            car.angle = 180;
            cars_.push(car);
        }
        add(debugLayer_);
	}

	public override function update(elapsed:Float):Void
	{
        if (debugLayer_ != null) {
            debugLayer_.fill(FlxColor.TRANSPARENT);
        }

		super.update(elapsed);

        for (i in 0...cars_.length) {
            var carA = cars_[i];
            var aabb = carA.getAABB();
            var obb = carA.getOBB();
            for (j in i+1...cars_.length) {
                var carB = cars_[j];
                if (testAABB(aabb, carB.getAABB())) {
                    carA.collideAABB = true;
                    carB.collideAABB = true;
                    if (testOBB(obb, carB.getOBB())) {
                        carA.collideOBB = true;
                        carB.collideOBB = true;
                    }
                }
            }

            if (FlxG.debugger.visible && debugLayer_ != null) {
                drawAABB(aabb,carA.collideAABB);
                drawOBB(obb,carA.collideOBB);
            }
        }

        for (player in players_) {
            player.update();
        }
	}

    private function testAABB(a : Rectangle, b : Rectangle) : Bool
    {
        if (a.x > b.x + b.width) return false;
        if (a.x + a.width < b.x) return false;
        if (a.y > b.y + b.height) return false;
        if (a.y + a.height < b.y) return false;
        return true;
    }

    private function testOBB(a: OBB, b: OBB) : Bool
    {
        var dispAB = b.c - a.c;
        var dispBA = -dispAB;

        // map a to frame of b, vice versa
        var vA = [
            Point.fromXY(-a.sz.x, -a.sz.y),
            Point.fromXY(-a.sz.x,  a.sz.y),
            Point.fromXY( a.sz.x,  a.sz.y),
            Point.fromXY( a.sz.x, -a.sz.y),
        ].map(function(p) return (p.fromFrame(a.axes) + dispBA).toFrame(b.axes));
        var vB = [
            Point.fromXY(-b.sz.x, -b.sz.y),
            Point.fromXY(-b.sz.x,  b.sz.y),
            Point.fromXY( b.sz.x,  b.sz.y),
            Point.fromXY( b.sz.x, -b.sz.y),
        ].map(function(p) return (p.fromFrame(b.axes) + dispAB).toFrame(a.axes));

        // find bottom, top, left, right
        var extremes = [Point.positiveInfinity,Point.negativeInfinity];
        var findMinmax = function(p : Point, acc : Array<Point>) {
            return [Point.fromXY(Math.min(p.x,acc[0].x),Math.min(p.y,acc[0].y)),
                    Point.fromXY(Math.max(p.x,acc[1].x),Math.max(p.y,acc[1].y))];
            };
        var minmaxA = vA.fold(findMinmax, extremes);
        var minmaxB = vB.fold(findMinmax, extremes);

        var minA = minmaxA[0];
        var maxA = minmaxA[1];
        var minB = minmaxB[0];
        var maxB = minmaxB[1];

        return ! (
            (
                (minA.x >  b.sz.x && maxA.x >  b.sz.x) ||
                (minA.x < -b.sz.x && maxA.x < -b.sz.x) ||
                (minA.y >  b.sz.y && maxA.y >  b.sz.y) ||
                (minA.y < -b.sz.y && maxA.y < -b.sz.y)
            ) || (
                (minB.x >  a.sz.x && maxB.x >  a.sz.x) ||
                (minB.x < -a.sz.x && maxB.x < -a.sz.x) ||
                (minB.y >  a.sz.y && maxB.y >  a.sz.y) ||
                (minB.y < -a.sz.y && maxB.y < -a.sz.y)
            )
        );
    }

    private function drawOBB(obb: OBB, collide : Bool) : Void
    {
        var color = collide ? FlxColor.RED : FlxColor.CYAN;
        var p= [
            Point.fromXY(-obb.sz.x,-obb.sz.y),
            Point.fromXY(-obb.sz.x, obb.sz.y),
            Point.fromXY( obb.sz.x, obb.sz.y),
            Point.fromXY( obb.sz.x,-obb.sz.y)
        ].map(function(p) return p.fromFrame(obb.axes) + obb.c);

        for (i in 0...p.length) {
            line(p[i],p[(i+1)%4],color);
        }
    }
    private function drawAABB(aabb : Rectangle, collide : Bool) : Void
    {
        var color = collide ? FlxColor.RED : FlxColor.CYAN;
        color.alpha = 127;
        debugLayer_.drawRect(aabb.x,aabb.y, aabb.width,aabb.height,
            FlxColor.TRANSPARENT,
            {color:color});
    }

    private function line(p1:Point,p2:Point,
                          c:FlxColor = FlxColor.BLACK,t :Int = 1) : Void
    {
        debugLayer_.drawLine(p1.x,p1.y,p2.x,p2.y,{thickness:t,color:c});

    }
}
