package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class PlayState extends FlxState
{
    var car : Car;
    var track : Track;

	override public function create():Void
	{
		super.create();

        track = new Track();
        add(track);
        car = new Car(10,10);
        add(car);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
