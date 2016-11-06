package;

import flixel.input.gamepad.FlxGamepad;

class Player implements Subject
{
    public var controller(default, null) : Control;
    public var id (default, null) : Int;
    public var ready(default, null) = false;
    public var color : Car.Color;

    private var observers_ : Array<Observer> = [];
    
    public static var numPlayers(default,null) = 0;

    public function new(c : Control)
    {
        controller = c;
        id = ++numPlayers;
    }

    private function handleInput() {
        if (!ready) {
            if (controller.ready()) {
                ready = true;
                notify(PLAYER_READY);
            }
            else if (controller.quit()) {
                --numPlayers;
                notify(PLAYER_QUIT);
                // TODO remove player from MenuState list
            }
        }
        else {
            if (controller.unready()) {
                ready = false;
                notify(PLAYER_UNREADY);
            }
            else if (controller.switchColor() != FORWARD) {
                // modify the colour from shared colour pool
            }
        }
    }

    public function update() {
        handleInput();
        if (controller.ready()) {
            trace("Ready pressed");
        }
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

