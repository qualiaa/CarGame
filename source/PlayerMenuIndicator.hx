package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
using flixel.tweens.FlxTween;

class PlayerMenuIndicator extends FlxSpriteGroup implements Observer
{
    public var player_(default,null) : Player;
    public var groupScale(default,set) : Float;

    var text_ : FlxText;

    var moveTween = FlxEase.circInOut;
    static inline var moveTime = 1.0;
    var entryTween = FlxEase.backOut;
    static inline var entryDelay = 0.5;
    static inline var entryTime = 1.0;
    var outTween = FlxEase.quintIn;
    static inline var outTime = 0.5;

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
    }

    public function onNotify(e: Event, s: Subject) : Void
    {
        switch(e) {
            case PLAYER_READY: playerReadyAction();
            case PLAYER_UNREADY: playerUnreadyAction();
            case PLAYER_QUIT: playerQuitAction();
        }
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
