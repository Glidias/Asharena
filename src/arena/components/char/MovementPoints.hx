package arena.components.char;

/**
 * Arena-game  specific character meters for turn-based combat.
 * @author ...
 */
class MovementPoints
{
	
	public var movementTimeLeft:Float;
	public var timeElapsed:Float;  // recorded time elapsed per frame

	public function new() 
	{
		
	}
	
	public inline function deplete(amt:Float):Void {
		timeElapsed = amt;
		movementTimeLeft -= amt;
	}
	
}