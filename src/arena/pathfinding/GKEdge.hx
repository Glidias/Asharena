package arena.pathfinding;

class GKEdge {
		
	public var from :Int; // The index of the node from which this edge departs
	public var to :Int; // The index of the node from which this edge arrives
	public var cost :Float; // The cost of crossing through this node
	public var flags:Int;
	
	public static inline var FLAG_GRADIENT_UNSTABLE:Int = 1;
	public static inline var FLAG_GRADIENT_DOWNWARD:Int = 2;
	public static inline var FLAG_GRADIENT_DIFFICULT:Int = 4;
	
	public static inline var DIAGONAL_LENGTH:Float = 1.4142135623730950488016887242097;
	
	public static inline var VALUE_CLIFF_UP:Int = (FLAG_GRADIENT_DIFFICULT | FLAG_GRADIENT_UNSTABLE);
	public static inline var VALUE_CLIFF_DOWN:Int = (FLAG_GRADIENT_DOWNWARD | FLAG_GRADIENT_UNSTABLE);
	public static inline var VALUE_INVALID:Int = -1;
	
	public function new (n_From:Int, n_To:Int, n_Cost:Float=1.0) {
		
		from = n_From;
		to = n_To;
		cost = n_Cost;
		flags = 0;
	}
	
	public inline function getGradientFromCost(nodes:Array<GKNode>):Float {
		return (nodes[from].x == nodes[to].x || nodes[from].y == nodes[to].y ? 1 : DIAGONAL_LENGTH ) - cost;
	}
}