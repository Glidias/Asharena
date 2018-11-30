package altern.culling;
import altern.terrain.ICuller;
import util.TypeDefs.Vector;
import util.TypeDefs.Vector3D;


/**
 * ...
 * @author Glidias
 */
class DefaultCulling implements ICuller
{

	public function new() 
	{
		
	}
	
	public var frustum:CullingPlane;
	
	
	public static function cullingInFrustumOf(frustum:CullingPlane, culling:Int, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Int 
	{
			var side:Int = 1;
			var plane:CullingPlane = frustum;
			while ( plane != null ) {
			if ( (culling & side)!=0 ) {
			if (plane.x >= 0)
			if (plane.y >= 0)
			if (plane.z >= 0) {
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else
			if (plane.z >= 0) {
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.y >= 0)
			if (plane.z >= 0) {
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.z >= 0) {
			if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			}
			side <<= 1;
			plane = plane.next;
			}
			return culling;
	}
	
	public static function isInFrontOfFrustum(ax:Float, ay:Float , az:Float, bx:Float , by:Float, bz:Float, cx:Float, cy:Float, cz:Float, frustumCorners:Vector<Vector3D>):Bool {
		var x:Float = frustumCorners[0].x;
		var y:Float = frustumCorners[0].y;
		var z:Float = frustumCorners[0].z;
		var acz:Float;
		var normalX:Float;
		var normalY:Float;
		var acx:Float;
		var acy:Float;
		var abz:Float;
		var normalZ:Float;
		var aby:Float;
		var abx:Float;
		abx = bx - ax;
		aby = by - ay;
		abz = bz - az;
		acx = cx - ax;
		acy = cy - ay;
		acz = cz - az;
		normalX = acz*aby - acy*abz;
		normalY = acx*abz - acz*abx;
		normalZ = acy * abx - acx * aby;
		var offset:Float = ax * normalX + ay * normalY + az * normalZ;
		
		if (normalX * x + normalY * y + normalZ * z <= offset) {
			return false;
		}
		
		/*
		var v:Vector3D;
		for (i in 0...frustumCorners.length) {
			v = frustumCorners[i];
			x = v.x;
			y = v.y;
			z = v.z;
			
		}
		*/
		
		var outside:Bool;
		var inside:Bool;
		var different:Bool;
		var c:Vector3D;
		outside = false;
		inside = false;
		different = false;
		for (i in 0...frustumCorners.length) {
			c = frustumCorners[i];
			if ( normalX * c.x + normalY * c.y + normalZ * c.z >= offset) {
				inside = true;
			}
			else {
				outside = true;
			}
			if (inside && outside) {
				different = true;
				break;
			}
			
		}

		return different;
	}
	
	
	public static function triInFrustumCover(frustum:CullingPlane, ax:Float, ay:Float , az:Float, bx:Float , by:Float, bz:Float, cx:Float, cy:Float, cz:Float):Bool {
			//var lastPlane:CullingPlane = null;
			var plane:CullingPlane = frustum;
			while ( plane != null) {
				if (ax * plane.x + ay * plane.y + az * plane.z < plane.offset && 
				bx  * plane.x + by * plane.y + bz * plane.z < plane.offset && 
				cx * plane.x + cy * plane.y + cz * plane.z < plane.offset  ) {
					return false;
				}
				//lastPlane = plane;
				
				plane = plane.next;
			}
			
			/*
			plane = lastPlane;  // far-clip special case, intersecting it counts
			if (ax * plane.x + ay * plane.y + az * plane.z < plane.offset || 
				bx  * plane.x + by * plane.y + bz * plane.z < plane.offset || 
				cx * plane.x + cy * plane.y + cz * plane.z < plane.offset  ) {
				return false;
			}
			*/
			
			return true;
		}
	
	/* INTERFACE altern.terrain.ICuller */
	
	public function cullingInFrustum(culling:Int, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Int 
	{
			var side:Int = 1;
			var plane:CullingPlane = frustum;
			while ( plane != null ) {
			if ( (culling & side)!=0 ) {
			if (plane.x >= 0)
			if (plane.y >= 0)
			if (plane.z >= 0) {
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else
			if (plane.z >= 0) {
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.y >= 0)
			if (plane.z >= 0) {
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.z >= 0) {
			if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			}
			side <<= 1;
			plane = plane.next;
			}
			return culling;
	}
	
}