package components;
import util.geom.XYZ;

/**
 * For character basic collision detection.
 * @author Glenn Ko
 */
class Ellipsoid implements XYZ
{
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(x:Float=32,y:Float=32,z:Float=32) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
}