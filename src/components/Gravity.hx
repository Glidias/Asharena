package components;
import util.geom.XYZ;

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
	
	public inline function update(vel:XYZ, time:Float):Void {
		vel.z -= force * time;
	}
}