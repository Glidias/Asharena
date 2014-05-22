package arena.components.char;
import flash.Vector;
import util.geom.Vec3;

/**
 * Component to support stealth aspects (environment 3d detection) in turn-based action RPG.
 * A set of random-uniform generated points within players' bounding ellipsoid for periodic enemy spot-check raycasts to determine whether active player(s) gets spotted by enemy units
 * or player(s) succesfullly remains hidden behind cover. The ellipsoid point samples in this component are normalized to unit length sphere proportion (1,1,1) so it can be reused
 * with other character entities that have similar body proportions. 
 * Since points are evenly distributed to fill the entire volume of the ellipsoid, the center of mass should mostly be sampled during random spot-checks, so players should try to the center of mass
 * of their bodies hidden behind cover as much as possible to avoid enemy detection. If the ellipsoid is touched, more accruate body detection like hit-boxes may be done if more realism is required.
 * 
 * @author Glenn Ko
 */
class EllipsoidPointSamples
{

	private static inline var phi:Float = 3;
	var a:Float;
	var b:Float;
	var c:Float;
	
	public var points:Vector<Float>;
	public var numPoints:Int;
	
	public function new() 
	{
		
	}
	
	public function init(ellipsoid:Vec3, numPoints:Int = 100):EllipsoidPointSamples {
		a = ellipsoid.x;
		b = ellipsoid.y;
		c = ellipsoid.z;
		var d:Float = 1 / Math.sqrt( a * a + b * b + c * c );
		a *= d;
		b *= d;
		c *= d;
		
		d = max(a, b, c);
	
		this.numPoints = numPoints;
		points = new Vector<Float>(numPoints, true);
		
		return this;
	}
	
	
	private inline function mx(x:Float, y:Float):Float {
		return x > y ? x : y;
	}
	private inline function max(x:Float, y:Float, z:Float):Float {
		return mx( mx(x, y), mx(x, z) );
	}
	
	private inline function check(x:Float, y:Float, z:Float):Bool {
		return  (((x / a) * 2 + (y / b) * 2 + (z / c) * 2) <= 1);  // what is double asterisk??
	}
	
	
		

	
}