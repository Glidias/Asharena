package components;
import util.geom.XYZ;

/**
 * ...
 * @author Glenn Ko
 */
class Damp
{
	public var ratio:Float;

	public function new(ratio:Float=0.9) 
	{
		this.ratio = ratio;
	}
	
	public inline function update(vel:XYZ, time:Float):Void {
		time = Math.exp(( -time) / ratio);
		vel.x *= ratio * time;
		vel.y *= ratio * time;
		vel.z *= ratio * time;
	}
	
}