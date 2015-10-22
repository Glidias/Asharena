package arena.systems.player;
import util.geom.Vec3;

/**
 * ...
 * @author Glenn Ko
 */
class PlayerAggro
{

	public var loiterTime:Float;  	// the amount of loiter time accumulated before reaching threshold
	public var loiterTimeThreshold:Float; // reaction time interval while loitering to re-update relavant aggro states
	
	// pinned grid position is measured in half steps
	public var lastGridPositionX:Int;
	public var lastGridPositionY:Int;
	public var gridStepThreshold:Int; // the amount of grid half steps required to travel from current pinned grid position to re-update relavant aggro states (usually set to >=2 to avoid straddling partition issues)
	
	public var lastPositionAnalog:Vec3;  // pinned analog position
	public var analogDistThreshold:Float;  // the amount of distance required to travel from currently pinned position in order to re-update relavant aggro states.
	

	public function new() 
	{
		
	}
	
	public function init():PlayerAggro {
		loiterTime = 0;
		lastPositionAnalog = new Vec3();
		lastGridPositionX = 0;
		lastGridPositionY = 0;
		
		gridStepThreshold = 2;
		analogDistThreshold = 32;
		loiterTimeThreshold = 0.213;  
		
		return this;
	}
	
	
	public inline function updateAnalog(x:Float, y:Float, z:Float):Void {
		lastPositionAnalog.x = x;
		lastPositionAnalog.y = y;
		lastPositionAnalog.z = z;
	}
	
	public inline function updateGridPosition(x:Int, y:Int):Void {
		lastGridPositionX = x;
		lastGridPositionY = y;
	}
	
	public inline function reset():Void {
		loiterTime = 0;
	}
	
}