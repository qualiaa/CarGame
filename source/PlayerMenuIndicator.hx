package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
using flixel.tweens.FlxTween;

class PlayerMenuIndicator extends FlxSpriteGroup implements Observer
{
    public var player_(default,null) : Player;
    public var groupScale(default,set) : Float;
    public var car_ : Car;

    var text_ : FlxText;

    static var carOffset = Point.fromXY(0, -100);

    var moveTween = FlxEase.circInOut;
    static inline var moveTime = 1.0;
    var entryTween = FlxEase.backOut;
    static inline var entryDelay = 0.5;
    static inline var entryTime = 1.0;
    var outTween = FlxEase.quintIn;
    static inline var outTime = 0.5;

    static var rotateTimer_ = new FlxTimer();
    static inline var rotateTime_ = 8.0;
    static var scaleTimer_ = new FlxTimer();
    static inline var scaleTime_ = 4.0;
    static inline var startScale = 5;
    static inline var dScale = 0.5;

    static var indicatorCoords_ = [
            [{x:1/2, y:1/2}],
            [{x:1/4, y:1/2}, {x:3/4, y:1/2}],
            [{x:1/4, y:1/2}, {x:1/2, y:1/2}, {x:3/4, y:1/2}],
            [{x:1/4, y:1/4}, {x:3/4, y:1/4}, {x:1/4, y:3/4}, {x:3/4, y:3/4}]
        ];

    public function new(i: Int, n: Int, p : Player)
    {
        var pos = getPositionFromIndex(i, n);
        super(pos.x,pos.y);
        player_ = p;
        text_ = new FlxText(0,0,0,"Player " + player_.id);
        text_.alignment = CENTER;
        add(text_);

        groupScale = 0;
        tween({groupScale: 1.0}, entryTime, {
            ease: entryTween,
            startDelay: entryDelay
        });
        car_ = new Car(null, x, y);
        car_.scale=FlxPoint.get(startScale,startScale);
        car_.position += carOffset;
        car_.carColor = player_.color;
        FlxG.state.add(car_);

        if (!rotateTimer_.active) {
            rotateTimer_.start(rotateTime_,null,0);
        }
        if (!scaleTimer_.active) {
            scaleTimer_.start(scaleTime_,null,0);
        }
    }

    public function onNotify(e: Event, s: Subject) : Void
    {
        switch(e) {
            case PLAYER_SWITCH_COLOR: car_.carColor = player_.color;
            case PLAYER_READY: playerReadyAction();
            case PLAYER_UNREADY: playerUnreadyAction();
            case PLAYER_QUIT: playerQuitAction();
            default:
        }
    }

    public override function update(dt:Float) : Void
    {
        car_.angle = 360 * rotateTimer_.progress;
        var s = startScale + dScale*Math.sin(scaleTimer_.progress*2*Math.PI);
        car_.scale = FlxPoint.get(s,s);
        car_.x = x;
        car_.y = y;
        car_.position += carOffset;
        car_.positionWheels();
    }

    public function setTargetIndex(i : Int, n : Int) : Void
    {
        var p = getPositionFromIndex(i,n);
        setTargetPosition(p.x,p.y);
    }

    private function setTargetPosition(x: Float, y: Float) : Void
    {
        tween({x:x,y:y}, moveTime, { ease: moveTween });
    }

    private function getPositionFromIndex(i : Int, n : Int)
    {
        var coords = indicatorCoords_[n-1][i];
        var x = FlxG.width * coords.x;
        var y = FlxG.height * coords.y;
        return {x:x,y:y};
    }

    public function set_groupScale(s : Float) : Float
    {
        groupScale = s;
        forEachOfType(FlxSprite, function(e : FlxSprite) {
            e.scale = FlxPoint.get(s,s);
        });
        return s;
    }


    private function playerReadyAction() : Void
    {
        text_.text = "Player " + player_.id + "\nREADY";
    }

    private function playerUnreadyAction() : Void
    {
        text_.text = "Player " + player_.id;
    }

    private function playerQuitAction() : Void
    {
        text_.text = "Player " + player_.id + "\nQUIT";
        tween({groupScale: 0}, outTime, {
            ease: outTween,
            onComplete: function(t) { FlxG.state.remove(this); }
        });
    }
}
