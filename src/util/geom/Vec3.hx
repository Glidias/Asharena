/**
 * ...
 * @author Glenn Ko
 */

package util.geom;

class Vec3 implements XYZ
{
	public static var ZERO:Vec3 = new Vec3(0, 0, 0);
	public static var X_AXIS:Vec3 = new Vec3(1, 0, 0);
	public static var Y_AXIS:Vec3 = new Vec3(0, 1, 0);
	public static var Z_AXIS:Vec3 = new Vec3(0, 0, 1);

	public static var RIGHT:Vec3 = new Vec3(1, 0, 0);
	public static var LEFT:Vec3 = new Vec3(-1, 0, 0);

	public static var FORWARD:Vec3 = new Vec3(0, 1, 0);
	public static var BACK:Vec3 = new Vec3(0, -1, 0);

	public static var UP:Vec3 = new Vec3(0, 0, 1);
	public static var DOWN:Vec3 = new Vec3(0, 0, -1);
		
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	

	// -- Getters (inline)
	
	inline public function length():Float {
		return Math.sqrt(x*x + y*y + z*z);
	}
	
	inline public function lengthSqr():Float {
		return x*x + y*y + z*z;
	}	
	
	inline public function dotProduct(v:XYZ):Float {
		return x*v.x + y*v.y + z*v.z;
	}
	
	inline public function crossProduct(v:XYZ):Vec3 {
		return new Vec3(y*v.z - z*v.y, z*v.x - x*v.z,  x*v.y - y*v.x);
	}
	
	inline public function clone():Vec3 {
		return new Vec3(x, y, z);
	}
	
	inline public function isZeroVector():Bool {
		return lengthSqr() == 0;
	}
	
	
	// -- Setters (inline)
	
	inline public function crossProductSet(v:XYZ):Void {
		x = y * v.z - z * v.y;
		y = z * v.x - x * v.z;
		z = x * v.y - y * v.x;
	}
	
	inline public function add(v:XYZ):Void {
		x += v.x;
		y += v.y;
		z += v.z;
	}

	inline public function addScaled(k:Float, v:XYZ):Void {
		x += k*v.x;
		y += k*v.y;
		z += k*v.z;
	}


	inline public function subtract(v:XYZ):Void {
		x -= v.x;
		y -= v.y;
		z -= v.z;
	}
		

	inline public function sum(a:XYZ, b:XYZ):Void {
		x = a.x + b.x;
		y = a.y + b.y;
		z = a.z + b.z;
	}


	inline public function diff(a:XYZ, b:XYZ):Void {
		x = a.x - b.x;
		y = a.y - b.y;
		z = a.z - b.z;
	}

	inline public function scale(k:Float):Void {
		x *= k;
		y *= k;
		z *= k;
	}
	
	inline public function reverse():Void {
		x = -x;
		y = -y;
		z = -z;
	}

	inline public function transform3(m:Mat3):Void {
		x = m.a*x + m.b*y + m.c*z;
		y = m.e*x + m.f*y + m.g*z;
		z = m.i*x + m.j*y + m.k*z;
	}
	
	inline public function transformTransposed3(m:Mat3):Void {
		x = m.a*x + m.e*y + m.i*z;
		y = m.b*x + m.f*y + m.j*z;
		z = m.c*x + m.g*y + m.k*z;
	}
		
	inline public function reset():Void {
		x = y = z = 0;
	}
	
    inline public function set(param1:Float, param2:Float, param3:Float) : Void
    {
        x = param1;
        y = param2;
		z = param3;
    }


	inline public function saveTo(result:XYZ):Void {
		result.x = x;
		result.y = y;
		result.z = z;
	}
		
	inline public function copyFrom(source:XYZ):Void {
		x = source.x;
		y = source.y;
		z = source.z;
	}
		
	
	inline public function transform4(m:IMat4):Void {
		x = m.a*x + m.b*y + m.c*z + m.d;
		y = m.e*x + m.f*y + m.g*z + m.h;
		z = m.i*x + m.j*y + m.k*z + m.l;
	}
		

	inline public function transformTransposed4(m:IMat4):Void {
		var xx:Float = x - m.d;
		var yy:Float = y - m.h;
		var zz:Float = z - m.l;
		x = m.a*x + m.e*y + m.i*z;
		y = m.b*x + m.f*y + m.j*z;
		z = m.c*x + m.g*y + m.k*z;
	}
		

	inline public function transformVector4(m:IMat4):Void {
		x = m.a*x + m.b*y + m.c*z;
		y = m.e*x + m.f*y + m.g*z;
		z = m.i*x + m.j*y + m.k*z;
	}
	
	// -- Optional inlines
	
	// -- Setters 

	inline public function assignAddition(v1:XYZ, v2:XYZ):Void {
		x = v1.x + v2.x;
		y = v1.y + v2.y;
		z = v1.z + v2.z;
	}
	
	// normalization

	#if (iA_x||iNormalize_x) inline #end
	public function normalize() : Void {
        scale(1 / length()); 
    }
	
	#if (iA_x||iNormalize_x) inline #end
	function normalizeWithSquared(squaredLength:Float):Void {
		scale(1 / Math.sqrt( squaredLength )); // assumed non-zero-length vector
	}

	/*
	public function normalizeWithSquaredCheck():Void {
		normalizeWithSquaredCheck2( lengthSqr()  );
	}
	public function normalizeWithSquaredCheck2(squaredLength:Float):Void {
		if (squaredLength ==0 ) {  // checks for non-zero-length vector and use default x-axis?
			x = 1;
			y = 0;
			z = 0;
		}
		else {
			scale(1 / Math.sqrt(squaredLength));
		}
	}
	*/
	
	// length setting
	
	#if (iA_x||iLength_x) inline #end
	public function setLength(val:Float):Void {
		var k:Float = val/length();
		x *= k;
		y *= k;
		z *= k;
	}
	/*
	public function setLengthSquaredCheck(length:Float):Void {
		setLengthSquaredCheck2(length, lengthSqr() );
	}
	public function setLengthSquaredCheck2(length:Float, squaredLength:Float):Void {
		if (squaredLength== 0) { // check for non-zero-length vector and use default x-axis?
			x = length;
			y = 0;
			z = 0;
		} else {
			var k:Float = length/Math.sqrt(squaredLength);
			x *= k;
			y *= k;
			z *= k;
		}
	}
	*/
	
	// misc
	
	#if (iA_x||iRemoveComponent_x) inline #end
	public function removeComponent(axis:Vec3) : Void
    {
        var scalar:Float = dotProduct(axis);
        this.x = this.x - axis.x * scalar;
        this.y = this.y - axis.y * scalar;
        this.z = this.z - axis.z * scalar;
    }

	
	// -- Getters 
	
	#if (iA_x||iDistance_x) inline #end
	public function distanceTo(v:Vec3):Float {
		var dx:Float = x - v.x;
		var dy:Float = y - v.y;
		var dz:Float = z - v.z;
		return Math.sqrt(dx*dx + dy*dy + dz*dz);
	}
	

	
	// -- Getters (non-inlined)
	public function toString():String {
		return "Vec3(" + x + ", " + y + ", " + z + ")";
	}
	
	
	// STATIC METHOD DUPLICATES
	
	// Create Vec3
	
	inline public static function copy(v:Vec3):Vec3 {
		return new Vec3(v.x, v.y, v.z);
	}
	
	inline public static function createCross(v1:Vec3, v2:Vec3):Vec3 {
		return new Vec3(v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z,  v1.x*v2.y - v1.y*v2.x);
	}
	
	inline public static function createAdd(v1:Vec3, v2:Vec3):Vec3 {
        return new Vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
    }
	
	inline public static function createSubtract(v1:Vec3, v2:Vec3):Vec3 {
        return new Vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
    }
	
	inline public static function createScale(v:Vec3, scaleAmt:Dynamic):Vec3 {
        return new Vec3(v.x*scaleAmt, v.y*scaleAmt, v.z*scaleAmt);
    }
	
	inline public static function createProjection(v:Vec3, axis:Vec3):Vec3 {
		var scalar:Float = dot(v, axis); 
        return new Vec3(v.x - axis.x * scalar, v.y - axis.y * scalar, v.z - axis.z * scalar);
    }		
	
	// Retrieve/ Write
	
	inline public static function dot(v1:Vec3, v2:Vec3):Float {
		return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
	}
	
	inline public static function lengthOf(v:XYZ):Float {
		return Math.sqrt(squareLengthOf(v));
	}
	inline public static function squareLengthOf(v:XYZ):Float {
		return v.x * v.x + v.y * v.y + v.z * v.z;
	}

    inline public static function writeCross(v1:Vec3, v2:Vec3, output:Vec3):Void
    {
       output.x = v1.y * v2.z - v1.z * v2.y;
       output.y = v1.z * v2.x - v2.z * v1.x;
       output.z = v1.x * v2.y - v1.y * v2.x;
    }
	inline public static function writeProjection(v:Vec3, axis:Vec3, output:Vec3):Void {
		var scalar:Float = dot(v, axis); 
		output.x = v.x - axis.x * scalar;
		output.y =  v.y - axis.y * scalar;
		output.z = v.z - axis.z * scalar;
    }	
	
	inline public static function writeSubtract(output:Vec3, input:Vec3):Void {
		output.x -= input.x;
		output.y -= input.y;
		output.z -= input.z;
	}
	inline public static function writeAdd(output:Vec3, input:Vec3):Void {
		output.x += input.x;
		output.y += input.y;
		output.z += input.z;
	}
	inline public static function writeScale(output:Vec3, scaleAmt:Float):Void {
		output.x *= scaleAmt;
		output.y *= scaleAmt;
		output.z *= scaleAmt;
	}
	
}