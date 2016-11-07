package;

import flixel.input.gamepad.FlxGamepad;

class Player implements Subject
{
    public var control(default, null) : Control;
    public var id        (default, null) : Int;
    public var steerAngle(default, null) = 0.0;
    public var ready     (default, null) = false;
    public var inGame    (default, null) = false;
    public var color : Car.Color;

    private var observers_ : Array<Observer> = [];

    public static var numPlayers(default,null) = 0;

    public function new(c : Control)
    {
        control = c;
        id = ++numPlayers;
        color = Yellow;
    }

    private function handleInput() {
        if (!inGame)
        {
            if (!ready)
            {
                if (control.ready())
                {
                    ready = true;
                    notify(PLAYER_READY);
                }
                else if (control.back())
                {
                    --numPlayers;
                    notify(PLAYER_QUIT);
                    // TODO remove player from MenuState list
                }
            }
            else //ready
            {
                if (control.unready())
                {
                    ready = false;
                    notify(PLAYER_UNREADY);
                }
                else if (control.switchColor() != FORWARD)
                {
                    // modify the colour from shared colour pool
                }
            }

            if (control.steer()) {
                notify(CONTROL_STEER);
            }

            if (control.accelerate()) {
                notify(CONTROL_ACCELERATE);
            }

            if (control.brake()) {
                notify(CONTROL_BRAKE);
            }
        }
        else //inGame
        {
        }
    }

    public function update() {
        handleInput();
    }

    public function register(o : Observer)
    {
        if (observers_.indexOf(o) == -1) {
            observers_.push(o);
        }
    }
    public function deregister(o : Observer)
    {
        observers_.remove(o);
    }
    private function notify(e: Event) {
        for (o in observers_)
        {
            o.onNotify(e, this);
        }
    }
}

