package components;
import util.geom.Vec3;


/**
 * Dynamic collisions marker state.
 * Marker class to indicate entities that are collidable with other entities, and whether it can fall asleep or not if left idle for some time.
 * 
 * Will include collision masks and other stuffs later on.
 * @author Glenn Ko
 */
class MovableCollidable
{
	public var sleepable:Bool;
	public var sleepTime:Float;
	public var pos:Vec3;  // the position to integrate and test over time
	public var vel:Vec3;  // the velocity used for integration
	public var priority:Int;
	
	public function new() 
	{
		
	}
	
	public function init():MovableCollidable {
		init_i();
		pos = new Vec3();
		vel = new Vec3();
		priority = 0;
		return this;
	}
	
	public inline function init_i(isSleepable:Bool=false):Void {
		sleepTime = 0;
		sleepable = isSleepable;
		
	}
	
	inline
	public  function integrate(time:Float):Void
	{
		pos.x += vel.x * time;
		pos.y += vel.y * time;
		pos.z += vel.z * time;
	}
	
}