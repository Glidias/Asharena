package arena.pathfinding;

class GKNode {

	public var index :Int;
	//public var pos :RCVector;
	public var x:Int;
	public var y:Int;

		
	public function new (idx:Int, x:Int, y:Int) { //, n_Pos:RCVector
		
		index = idx;
		this.x = x;
		this.y = y;
		//pos = n_Pos;
	}
	
	public function toString():String {
		return "([GKNode]" + x + ", " + y + ")";
	}
}