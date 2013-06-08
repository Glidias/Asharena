package systems;

/**
 * @author richard
 */
class SystemPriorities
{
    public static inline var preUpdate:Int = 1;
    public static inline var update:Int = 2;
	public static inline var preSolveCollisions:Int = 3;
	public static inline var solveCollisions:Int = 4;
	public static inline var preMove:Int = 5;
    public static inline var move:Int = 6;
	public static inline var postMove:Int = 7;
    public static inline var resolveCollisions:Int = 8;
    public static inline var stateMachines:Int = 9;
    public static inline var animate:Int = 10;
    public static inline var render:Int = 11;
	 public static inline var postRender:Int = 12;
}
