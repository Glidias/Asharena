package components;
import util.geom.Vec3;

/**
 * ...
 * @author Glenn Ko
 */
class Gravity
{
	public var force:Float;

	public function new(force:Float) 
	{
		this.force = force;
	}
	
	public inline function update(vel:Vec3, time:Float):Void {
		vel.z -= force;
		
	}
}