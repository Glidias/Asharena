package util.geom;
#if nme
import nme.geom.Rectangle;
#elseif flash
import flash.geom.Rectangle;
#else
import jeash.geom.Rectangle;
#end

/**
 * ...
 * @author Glenn Ko
 */

class AABBUtils 
{
	public static inline var MAX_VALUE:Float = 1.7976931348623157e+308;
	public static inline var THRESHOLD:Float = .1;
	
	public static inline function getRect(aabb:IAABB, threshold:Float=THRESHOLD):Rectangle {
		return new Rectangle(aabb.minX, aabb.minZ, clampMagnitude(aabb.maxX - aabb.minX, threshold), clampMagnitude(aabb.maxZ - aabb.minZ, threshold) );
	
	}
	public static inline function clampMagnitude(mag:Float, threshold:Float=THRESHOLD):Float {
		return mag < 0 ? threshold : mag <  threshold ?  threshold : mag;
	}

	private static inline function abs(val:Float):Float {
		return val < 0 ? -val : val;
	}
	private static inline function norm(w:Int):Int 
	{
		return w != 0 ?  w < 0 ? -1 : 1 : 0;
	}
	
	public static inline function getString(aabb:IAABB):String {
		return "AABB: "+[aabb.minX, aabb.minY, aabb.minZ, aabb.maxX, aabb.maxY, aabb.maxZ];
	}
	
	public static inline function pointInside(aabb:IAABB, pt:XYZ):Bool {
		return !(pt.x < aabb.minX || pt.y < aabb.minY || pt.z < aabb.minZ || pt.x > aabb.maxX || pt.y > aabb.maxY || pt.z > aabb.maxZ);
	}
	
	
	
	public static inline function match(aabb:IAABB, refAABB:IAABB):Void {
		aabb.minX = refAABB.minX;
		aabb.minY = refAABB.minY;
		aabb.minZ = refAABB.minZ;
		
		aabb.maxX = refAABB.maxX;
		aabb.maxY = refAABB.maxY;
		aabb.maxZ = refAABB.maxZ;
	}
	
	public static inline function reset(aabb:IAABB):Void {
		aabb.minX = MAX_VALUE;
		aabb.minY = MAX_VALUE;
		aabb.minZ = MAX_VALUE;
		aabb.maxX = -MAX_VALUE;
		aabb.maxY = -MAX_VALUE;
		aabb.maxZ = -MAX_VALUE;
	}
	
	public static inline function expand2(aabb:IAABB, refAABB:IAABB):Void {
		if (refAABB.minX < aabb.minX) aabb.minX = refAABB.minX;
		if (refAABB.minY < aabb.minY) aabb.minY = refAABB.minY;
		if (refAABB.minZ < aabb.minZ) aabb.minZ = refAABB.minZ;
		
		if (refAABB.maxX > aabb.maxX) aabb.maxX = refAABB.maxX;
		if (refAABB.maxY > aabb.maxY) aabb.maxY = refAABB.maxY;
		if (refAABB.maxZ > aabb.maxZ) aabb.maxZ = refAABB.maxZ;
	}

	public static inline function expand(x:Float, y:Float, z:Float, aabb:IAABB):Void {
		if (x < aabb.minX) aabb.minX = x;
		if (y < aabb.minY) aabb.minY = y;
		if (z < aabb.minZ) aabb.minZ = z;
		if (x > aabb.maxX) aabb.maxX = x;
		if (y > aabb.maxY) aabb.maxY = y;
		if (z > aabb.maxZ) aabb.maxZ = z;
	}
	public static inline function expandWithPoint(vec:XYZ, aabb:IAABB):Void {
		if (vec.x < aabb.minX) aabb.minX = vec.x;
		if (vec.y < aabb.minY) aabb.minY = vec.y;
		if (vec.z < aabb.minZ) aabb.minZ = vec.z;
		if (vec.x > aabb.maxX) aabb.maxX = vec.x;
		if (vec.y > aabb.maxY) aabb.maxY = vec.y;
		if (vec.z > aabb.maxZ) aabb.maxZ = vec.z;
	}
	
	// -- Alternativa3d methods

	/*
		public function checkRays(origins:Array<XYZ>, directions:Array<XYZ>, raysLength:Int):Bool {
			for (var i:int = 0; i < raysLength; i++) {
				var origin:Vector3D = origins[i];
				var direction:Vector3D = directions[i];
				if (origin.x >= minX && origin.x <= maxX && origin.y >= minY && origin.y <= maxY && origin.z >= minZ && origin.z <= maxZ) return true;
				if (origin.x < minX && direction.x <= 0 || origin.x > maxX && direction.x >= 0 || origin.y < minY && direction.y <= 0 || origin.y > maxY && direction.y >= 0 || origin.z < minZ && direction.z <= 0 || origin.z > maxZ && direction.z >= 0) continue;
				var a:Number;
				var b:Number;
				var c:Number;
				var d:Number;
				var threshold:Number = 0.000001;
				// Intersection of X and Y projection
				if (direction.x > threshold) {
					a = (minX - origin.x)/direction.x;
					b = (maxX - origin.x)/direction.x;
				} else if (direction.x < -threshold) {
					a = (maxX - origin.x)/direction.x;
					b = (minX - origin.x)/direction.x;
				} else {
					a = 0;
					b = 1e+22;
				}
				if (direction.y > threshold) {
					c = (minY - origin.y)/direction.y;
					d = (maxY - origin.y)/direction.y;
				} else if (direction.y < -threshold) {
					c = (maxY - origin.y)/direction.y;
					d = (minY - origin.y)/direction.y;
				} else {
					c = 0;
					d = 1e+22;
				}
				if (c >= b || d <= a) continue;
				if (c < a) {
					if (d < b) b = d;
				} else {
					a = c;
					if (d < b) b = d;
				}
				// Intersection of XY and Z projections
				if (direction.z > threshold) {
					c = (minZ - origin.z)/direction.z;
					d = (maxZ - origin.z)/direction.z;
				} else if (direction.z < -threshold) {
					c = (maxZ - origin.z)/direction.z;
					d = (minZ - origin.z)/direction.z;
				} else {
					c = 0;
					d = 1e+22;
				}
				if (c >= b || d <= a) continue;
				return true;
			}
			return false;
		}
		*/

		public static inline function checkSphere(aabb:IAABB, sphere:XYZW):Bool {
			return sphere.x + sphere.w > aabb.minX && sphere.x - sphere.w < aabb.maxX && sphere.y + sphere.w > aabb.minY && sphere.y - sphere.w < aabb.maxY && sphere.z + sphere.w > aabb.minZ && sphere.z - sphere.w < aabb.maxZ;
		}

		
		public static inline function intersectRay(aabb:IAABB, origin:XYZ, direction:XYZ):Bool {
			if (origin.x >= aabb.minX && origin.x <= aabb.maxX && origin.y >= aabb.minY && origin.y <= aabb.maxY && origin.z >= aabb.minZ && origin.z <= aabb.maxZ) return true;
			if (origin.x < aabb.minX && direction.x <= 0) return false;
			if (origin.x > aabb.maxX && direction.x >= 0) return false;
			if (origin.y < aabb.minY && direction.y <= 0) return false;
			if (origin.y > aabb.maxY && direction.y >= 0) return false;
			if (origin.z < aabb.minZ && direction.z <= 0) return false;
			if (origin.z > aabb.maxZ && direction.z >= 0) return false;
			var a:Float;
			var b:Float;
			var c:Float;
			var d:Float;
			var threshold:Float = 0.000001;
			// Intersection of X and Y projection
			if (direction.x > threshold) {
				a = (aabb.minX - origin.x) / direction.x;
				b = (aabb.maxX - origin.x) / direction.x;
			} else if (direction.x < -threshold) {
				a = (aabb.maxX - origin.x) / direction.x;
				b = (aabb.minX - origin.x) / direction.x;
			} else {
				a = -1e+22;
				b = 1e+22;
			}
			if (direction.y > threshold) {
				c = (aabb.minY - origin.y) / direction.y;
				d = (aabb.maxY - origin.y) / direction.y;
			} else if (direction.y < -threshold) {
				c = (aabb.maxY - origin.y) / direction.y;
				d = (aabb.minY - origin.y) / direction.y;
			} else {
				c = -1e+22;
				d = 1e+22;
			}
			if (c >= b || d <= a) return false;
			if (c < a) {
				if (d < b) b = d;
			} else {
				a = c;
				if (d < b) b = d;
			}
			// Intersection of XY and Z projections
			if (direction.z > threshold) {
				c = (aabb.minZ - origin.z) / direction.z;
				d = (aabb.maxZ - origin.z) / direction.z;
			} else if (direction.z < -threshold) {
				c = (aabb.maxZ - origin.z) / direction.z;
				d = (aabb.minZ - origin.z) / direction.z;
			} else {
				c = -1e+22;
				d = 1e+22;
			}
			if (c >= b || d <= a) return false;
			return true;
		}
		
	
}