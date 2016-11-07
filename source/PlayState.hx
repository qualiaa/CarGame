package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class PlayState extends FlxState
{
    var track_ : Track;

    var players_ : Array<Player>;
    var cars_ : Array<Car> = [];

    public function new(players : Array<Player>) {
        super();
        players_ = players;
    }

	override public function create():Void
	{
		super.create();

        track_ = new Track();
        add(track_);

        for (player in players_) {
            var car = new Car(player,100,10);
            player.register(car);
            cars_.push(car);
        }
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

        for (player in players_) {
            player.update();
        }
	}
}
