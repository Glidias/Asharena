/**
 * ...
 * @author Glenn Ko
 */

package util.geom;
import flash.geom.Vector3D;

/**
 * Library of static Vec3 methods, and generic XYZ tuple values for parameters.
 */
class Vec3Utils 
{

	// Create Vec3

	
	inline public static function copy(v:XYZ):Vec3 {
		return new Vec3(v.x, v.y, v.z);
	}
	
	inline public static function createCross(v1:XYZ, v2:XYZ):Vec3 {
		return new Vec3(v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z,  v1.x*v2.y - v1.y*v2.x);
	}
	
	inline public static function createAdd(v1:XYZ, v2:XYZ):Vec3 {
        return new Vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
    }
	
	inline public static function createSubtract(v1:XYZ, v2:XYZ):Vec3 {
        return new Vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
    }
	
	inline public static function createScale(v:XYZ, scaleAmt:Float):Vec3 {
        return new Vec3(v.x*scaleAmt, v.y*scaleAmt, v.z*scaleAmt);
    }
	
	inline public static function createProjection(v:XYZ, axis:XYZ):Vec3 {
		var scalar:Float = dot(v, axis); 
        return new Vec3(v.x - axis.x * scalar, v.y - axis.y * scalar, v.z - axis.z * scalar);
    }		
	
	// Retrieve/ Write
	
	inline public static function matchValues(output:XYZ, withValue:XYZ):Void {
		output.x = withValue.x;
		output.y = withValue.y;
		output.z = withValue.z;
	}
	inline public static function matchValuesVector3D(output:XYZ, withValue:Vector3D):Void {
		output.x = withValue.x;
		output.y = withValue.y;
		output.z = withValue.z;
	}
	
	inline public static function dot(v1:XYZ, v2:XYZ):Float {
		return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
	}

    inline public static function writeCross(v1:XYZ, v2:XYZ, output:XYZ):Void
    {
       output.x = v1.y * v2.z - v1.z * v2.y;
       output.y = v1.z * v2.x - v2.z * v1.x;
       output.z = v1.x * v2.y - v1.y * v2.x;
    }
	inline public static function writeProjection(v:XYZ, axis:XYZ, output:XYZ):Void {
		var scalar:Float = dot(v, axis); 
		output.x = v.x - axis.x * scalar;
		output.y =  v.y - axis.y * scalar;
		output.z = v.z - axis.z * scalar;
    }	
	inline public static function normalize(v:XYZ):Void {
		
		var sc:Float = 1 / Math.sqrt( v.x * v.x + v.y * v.y + v.z * v.z );
		v.x *= sc;
		v.y *= sc;
		v.z *= sc;
	}
	
	inline public static function subtract(output:XYZ, input:XYZ):Void {
		output.x -= input.x;
		output.y -= input.y;
		output.z -= input.z;
	}
	inline public static function add(output:XYZ, input:XYZ):Void {
		output.x += input.x;
		output.y += input.y;
		output.z += input.z;
	}
	inline public static function scale(output:XYZ, scaleAmt:Float):Void {
		output.x *= scaleAmt;
		output.y *= scaleAmt;
		output.z *= scaleAmt;
	}
	
	inline public static function writeSubtract(output:Vec3, v1:XYZ, v2:XYZ):Vec3 
	{
		output.x = v1.x - v2.x;
		output.y = v1.y - v2.y;
		output.z = v1.z - v2.z;
		return output;
	}

	
	
}