/**
 * ...
 * @author Glenn Ko
 */

package util.geom;
import components.Vel;
import util.TypeDefs;

/**
 * Library of static Vec3 methods, and generic Vec3 tuple values for parameters.
 */
#if alternExpose @:expose #end
class Vec3Utils 
{

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
	
	inline public static function createScale(v:Vec3, scaleAmt:Float):Vec3 {
        return new Vec3(v.x*scaleAmt, v.y*scaleAmt, v.z*scaleAmt);
    }
	
	inline public static function createProjection(v:Vec3, axis:Vec3):Vec3 {
		var scalar:Float = dot(v, axis); 
        return new Vec3(v.x - axis.x * scalar, v.y - axis.y * scalar, v.z - axis.z * scalar);
    }		
	
	// Retrieve/ Write
	
	inline public static function matchValues(output:Vec3, withValue:Vec3):Void {
		output.x = withValue.x;
		output.y = withValue.y;
		output.z = withValue.z;
	}
	inline public static function matchValuesVector3D(output:Vec3, withValue:Vector3D):Void {
		output.x = withValue.x;
		output.y = withValue.y;
		output.z = withValue.z;
	}
	
	inline public static function dot(v1:Vec3, v2:Vec3):Float {
		return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
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
	inline public static function normalize(v:Vec3):Void {
		
		var sc:Float = 1 / Math.sqrt( v.x * v.x + v.y * v.y + v.z * v.z );
		v.x *= sc;
		v.y *= sc;
		v.z *= sc;
	}
	
	inline public static function subtract(output:Vec3, input:Vec3):Void {
		output.x -= input.x;
		output.y -= input.y;
		output.z -= input.z;
	}
	inline public static function add(output:Vec3, input:Vec3):Void {
		output.x += input.x;
		output.y += input.y;
		output.z += input.z;
	}
	inline public static function scale(output:Vec3, scaleAmt:Float):Void {
		output.x *= scaleAmt;
		output.y *= scaleAmt;
		output.z *= scaleAmt;
	}
	
	inline public static function writeSubtract(output:Vec3, v1:Vec3, v2:Vec3):Void 
	{
		output.x = v1.x - v2.x;
		output.y = v1.y - v2.y;
		output.z = v1.z - v2.z;
	}
	
	inline  public static function getLength(v:Vec3) :Float
	{
		return Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	}
	
	static public function sqDistBetween(a:Vec3, b:Vec3):Float {
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		var dz:Float = b.z - a.z;
		return dx * dx + dy * dy + dz * dz;
	}
	static public function sqDist2DBetween(a:Vec3, b:Vec3):Float {
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		return dx * dx + dy * dy;
	}
	
	static public function distBetween(a:Vec3, b:Vec3):Float {
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		var dz:Float = b.z - a.z;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	
	
}