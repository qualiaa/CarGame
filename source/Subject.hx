package;

interface Subject
{
    public function register(o : Observer) : Void;
    public function deregister(o : Observer) : Void;
}
