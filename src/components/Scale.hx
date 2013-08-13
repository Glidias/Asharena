package components;
import util.geom.Vec3;

/**
 * ...
 * @author Glenn Ko
 */
class Scale extends Vec3
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new(x:Float=0, y:Float=0, z:Float=0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
}