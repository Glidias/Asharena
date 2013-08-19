package systems {
	public class SystemPriorities {
		static public var preUpdate : int = 1;
		static public var update : int = 2;
		static public var preSolveCollisions : int = 3;
		static public var solveCollisions : int = 4;
		static public var preMove : int = 5;
		static public var move : int = 6;
		static public var postMove : int = 7;
		static public var resolveCollisions : int = 8;
		static public var stateMachines : int = 9;
		static public var animate : int = 10;
		static public var preRender : int = 11;
		static public var render : int = 12;
		static public var postRender : int = 13;
	}
}
