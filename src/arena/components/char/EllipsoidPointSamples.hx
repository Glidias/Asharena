package arena.components.char;
import flash.Vector;
import util.geom.PMath;
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
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var maxD:Float;
	
	public var points:Vector<Float>;
	public var numPoints:Int;
	
	private static inline var COS_0:Float = 1;
	private static inline var SIN_0:Float = 0;
	
	public function new() 
	{
		
	}
	
	public function init(ellipsoid:Vec3, numPoints:Int = 100):EllipsoidPointSamples {
	
		myInit(ellipsoid, numPoints);
		createRandomPoints3D();
		
		return this;
	}
	
	public function init2D(ellipsoid:Vec3, numPoints:Int = 100):EllipsoidPointSamples {
		
		myInit(ellipsoid, numPoints);
		createRandomPoints2D();
		
		return this;
	}
	
	public function sortVecFunc(a:Dynamic, b:Dynamic):Int {
		return a.w > b.w ? 1 : a.w < b.w ? -1 : 0;
	}
	
	
	public function sortPoints():Void {
		var arr:Array<Dynamic> = [];
		var count:Int = 0;
		
		var p:Dynamic;
		for (i in 0...numPoints) {
			
			arr.push( p = { x:points[count], y:points[count + 1], z:points[count +2] } );
			p.w = p.x * p.x + p.y * p.y + p.z * p.z;
			count+=3;
		}
		
		count = 0;
		arr.sort(sortVecFunc);
		for (i in 0...numPoints) {
			p = arr[i];
			points[count++] = p.x;
			points[count++] = p.y;
			points[count++] = p.z;
		}
	}
	
	private inline function myInit(ellipsoid:Vec3, numPoints:Int = 100):Void {
		a = ellipsoid.x;
		b = ellipsoid.y;
		c = ellipsoid.z;
		
		var d:Float = 1 / Math.sqrt( a * a + b * b + c * c );
		///*
		a *= d;
		b *= d;
		c *= d;
		//*/
		
		d = max(a, b, c); 
	
		//maxD = d;  // largest unit length
		maxD = 1 / d;		// scale largest unit length to 1 multiplier   (a or b or c)* (1/maxD)
		   
		this.numPoints = numPoints;
		points = new Vector<Float>(numPoints*3, true);
	}

	inline function createRandomPoints2D() 
	{
		var count:Int = 0;
		var x:Float;
		var y:Float;
		var z:Float;
		var rx:Float;
		var ry:Float;
		var rz:Float;
		
		var multiplierA:Float = 1 / maxD * 1/a;
		var multiplierB:Float = 1 / maxD * 1/b;
		var multiplierC:Float = 1 / maxD * 1/c;
		
		for (i in 0...numPoints) {
		
			while ( true ) {	
				x =  2 * a * (rand(0) - 0.5);
				y =  2 * b * (rand(0) - 0.5);
				z =  2 * c * (rand(0) - 0.5);
				if (check2(x,y)) {
					rx = x * COS_0 - y * SIN_0;
					ry = (x * SIN_0 + y * COS_0);
					rz = z;
					points[count++] = rx*multiplierA;
					points[count++] = ry*multiplierB;
					points[count++] = rz*multiplierC;
					break;
				}
			}
		}
		
		
	}
	
	inline function createRandomPoints3D() 
	{
		var count:Int = 0;
		var x:Float;
		var y:Float;
		var z:Float;
		var rx:Float;
		var ry:Float;
		var rz:Float;
		
		var multiplierA:Float = 1 / maxD * 1/a;
		var multiplierB:Float = 1 / maxD * 1/b;
		var multiplierC:Float = 1 / maxD * 1/c;
		
		for (i in 0...numPoints) {
		
			while ( true ) {	
				x =  2 * a * (rand(0) - 0.5);
				y =  2 * b * (rand(0) - 0.5);
				z =  2 * c * (rand(0) - 0.5);
				if (check(x,y,z)) {
					rx = x * COS_0 - y * SIN_0;
					ry = (x * SIN_0 + y * COS_0);
					rz = z;
					points[count++] = rx*multiplierA;
					points[count++] = ry*multiplierB;
					points[count++] = rz*multiplierC;
					break;
				}
			}
		}
	}
	
	private inline function oneOrZero():Float {
		return Math.random() > .5 ? 1 : 0;
	}
	
	private inline function ex(x:Float, y:Float):Float {
		return  a * (2 * x - 1);
	}
	
	private inline function ey(x:Float, y:Float):Float {
		var valuer:Float  = ((2 * x - 1));
		return  b * (Math.sqrt(1 -  exponentiation(valuer,2))) * (2 * y - 1);   //**2
	}
	
	inline function exponentiation(valuer:Float, amt:Float):Float 
	{
		return Math.pow(valuer, amt);// * amt;
	}
	
	
	
	private inline function rand(val:Float):Float {
		return val != 0 ? Math.random()*(1-val) + val : Math.random();
	}
	
	
	private inline function mx(x:Float, y:Float):Float {
		return x > y ? x : y;
	}
	private inline function max(x:Float, y:Float, z:Float):Float {
		return mx( mx(x, y), mx(x, z) );
	}
	
	private inline function check(x:Float, y:Float, z:Float):Bool {
		return check2(x, y) && check2(x, z) && check2(y, z);
		//return  (((x / a) * 2 + exponentiation((y / b),2)) + exponentiation((z / c), 2)) <= 1;  // what is double asterisk??
	}
	private inline function check2(x:Float, y:Float):Bool {
		//return true;
		return  ( exponentiation((x/a),2) + exponentiation((y/b),2) <= 1);  // what is double asterisk??
	}
	
		

	
}