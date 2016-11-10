package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
using flixel.tweens.FlxTween;

class MenuState extends FlxState implements Observer
{
    var activePads_ : Array<FlxGamepad> = [];
    var players_ : Array<Player> = [];
    var playerIndicators_ : Map<Player,PlayerMenuIndicator> =
        new Map<Player, PlayerMenuIndicator>();

    var maxPlayers_ = 4;


    static inline var gameStartTime : Int = 0;
    var startTimer = new FlxTimer();
    var gameTimerText : FlxText;

	override public function create():Void
	{
		super.create();

        FlxG.gamepads.reset();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        bgColor=FlxColor.fromInt(0xffc3cb7d);

        for (player in players_) {
            player.update();
        }

        var activeThisFrame = FlxG.gamepads.getActiveGamepads();
        if (activeThisFrame != null) {
            for (pad in activeThisFrame) {
                if (activePads_.indexOf(pad) == -1) {
                    addPad(pad);
                    trace(activeThisFrame.length + " pads active");
                }
            }
        }

        for (pad in activePads_) {
            if (pad.justPressed.START &&
                players_.filter(function(p) {
                    return p.control.id == pad.id;
                }).length == 0) {
                addPlayer(new PadControl(pad));
            }
        }
	}

    private function addPad(pad : FlxGamepad) : Void
    {
        activePads_.push(pad);
        trace("Pad " + pad.id + " active");
    }

    private function addPlayer(control : Control) : Void
    {
        if (players_.length == maxPlayers_) return;

        var p = new Player(control);
        var n = players_.length+1;
        /*
        moveIndicators(n, function() {
            addIndicator(player, n);
        });
        */
        moveIndicators(n);
        addIndicator(p,n);
        p.register(this);

        players_.push(p);
    }

    private function addIndicator(p : Player, n : Int) : Void {
        var indicator = new PlayerMenuIndicator(n-1,n,p);
        add(indicator);
        playerIndicators_.set(p,indicator);
        p.register(indicator);
    }

    private function removePlayer(p : Player) : Void
    {
        //remove(playerIndicators_[p]);
        playerIndicators_.remove(p);
        players_.remove(p);

        moveIndicators();
    }

    private function moveIndicators(?n : Null<Int>) : Void
    {
        if (n == null) {
            n = players_.length;
        }

        for (i in 0...players_.length) {
            var p = players_[i];
            var indicator =  playerIndicators_[p];
            indicator.setTargetIndex(i,n);
        }
    }

    private function startGame() : Void
    {
        trace("Starting game");

        FlxG.switchState(new PlayState(players_));
        for (player in players_) {
            player.deregister(this);
            player.deregister(playerIndicators_[player]);
        }
    }

    public function onNotify(e: Event, s : Subject)
    {
        switch(e) {
            case PLAYER_READY:
                if (players_.filter(function(p) {return p.ready;}).length ==
                        players_.length) {
                    startTimer.start(1.0,function(t) {
                        remove(gameTimerText);
                        gameTimerText = new FlxText(FlxG.width/2,20, 0,
                                "Starting in "+ t.loopsLeft);
                        add(gameTimerText);
                        if (t.loopsLeft == 0) {
                            startGame();
                        }
                    }, gameStartTime + 1);
                };
            case PLAYER_UNREADY:
                startTimer.reset();
            case PLAYER_QUIT:
                var target : Player = null;
                for (p in players_) {
                    if (p == s) {
                        target = p;
                        break;
                    }
                }
                removePlayer(target);
            default:
        }
    }
}
