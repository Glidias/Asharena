package components;
import util.geom.Vec3;

/**
 * Stores forward and right direction-facing vectors for entities.
 * @author Glenn Ko
 */
class DirectionVectors
{
	public var forward:Vec3;
	public var right:Vec3;

	public function new() 
	{
		forward = new Vec3();
		right = new Vec3();
	}
	
}