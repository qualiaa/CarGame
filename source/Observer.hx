package;

interface Observer
{
    public function onNotify(e: Event, s:Subject) : Void;
}
