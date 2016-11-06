package;

interface Control
{
    public var id(default,null) : Int;
    public var back : Void -> Bool;
    public var ready : Void -> Bool;
    public var unready : Void -> Bool;
    public var pause : Void -> Bool;
    public var quit : Void -> Bool;
    public var switchColor : Void -> Direction;
}
