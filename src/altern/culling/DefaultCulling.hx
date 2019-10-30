package altern.culling;
import altern.geom.ClipMacros;
import altern.geom.Face;
import altern.geom.Vertex;
import altern.geom.Wrapper;
import altern.terrain.ICuller;
import util.TypeDefs.Vector;
import util.TypeDefs.Vector3D;
import util.geom.Vec3;


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
		
		var c:Vector3D;
		var outside:Bool;
		var inside:Bool;
		var different:Bool;

		
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
	
	static var clippingTri:Face;
	static var clippingNormal:Vec3;
	
	static var clippingTri2:Face;
	static var clippingNormal2:Vec3;
	
	static function createNewTri():Face {
		var f:Face = new Face();
		var w:Wrapper;
		var v:Vertex;
		f.wrapper = w = new Wrapper();	
		w.vertex  = v =  new Vertex();
		
		w = w.next = new Wrapper();	 
		w.vertex = v.next = v = new Vertex();
		
		w = w.next = new Wrapper();	 
		w.vertex = v.next = v = new Vertex();
		
		return f;
	}
	public static var clippedFace:Face;
	public static inline function collectClippedFace():Void {
		var f:Face = clippedFace;
		f.destroy();
		f.collect();
	}
	
	public static var clippedFace2:Face;
	public static inline function collectClippedFace2():Void {
		var f:Face = clippedFace2;
		f.destroy();
		f.collect();
	}
	
	public static var CLIP_NEAR:Bool = false;
	
	public static function triInFrustumCover(frustum:CullingPlane, ax:Float, ay:Float , az:Float, bx:Float , by:Float, bz:Float, cx:Float, cy:Float, cz:Float):Int {
			var lastPlane:CullingPlane = null;	// assumed lastPlane is farClipping plane
			var clipNear:Bool = CLIP_NEAR;
			
			var nearClipPlane:CullingPlane = null;
			
			var plane:CullingPlane = frustum;
			while ( plane != null) {
				if (ax * plane.x + ay * plane.y + az * plane.z < plane.offset && 
				bx  * plane.x + by * plane.y + bz * plane.z < plane.offset && 
				cx * plane.x + cy * plane.y + cz * plane.z < plane.offset  ) {
					return -1;
				}
				
				lastPlane = plane;
				plane = plane.next;
				
				// 2nd last nearclip plane check
				if (clipNear && plane != null && plane.next == null) {
					nearClipPlane = plane;
				}
			}

			var result:Int = 0;
			plane = lastPlane;  // far-clip special case, intersecting it counts
			if (ax * plane.x + ay * plane.y + az * plane.z < plane.offset || 
				bx  * plane.x + by * plane.y + bz * plane.z < plane.offset || 
				cx * plane.x + cy * plane.y + cz * plane.z < plane.offset  ) 
			{
			
				if (clippingTri == null) {
					clippingTri = createNewTri();
					clippingNormal = new Vec3();
				}
			
				clippingTri.wrapper.vertex.x = ax;
				clippingTri.wrapper.vertex.y = ay;
				clippingTri.wrapper.vertex.z = az;
				
				clippingTri.wrapper.next.vertex.x = bx;
				clippingTri.wrapper.next.vertex.y = by;
				clippingTri.wrapper.next.vertex.z = bz;
				
				clippingTri.wrapper.next.next.vertex.x = cx;
				clippingTri.wrapper.next.next.vertex.y = cy;
				clippingTri.wrapper.next.next.vertex.z = cz;
				
				clippingNormal.x = plane.x;
				clippingNormal.y = plane.y;
				clippingNormal.z = plane.z;
				
				ClipMacros.computeMeshVerticesLocalOffsets(clippingTri, clippingNormal);
				clippedFace = ClipMacros.newPositiveClipFace(clippingTri, clippingNormal, plane.offset);
				
				result |= 1;
			}
			
						
			if (clipNear) {
				plane = nearClipPlane;
				if (ax * plane.x + ay * plane.y + az * plane.z < plane.offset || 
				bx  * plane.x + by * plane.y + bz * plane.z < plane.offset || 
				cx * plane.x + cy * plane.y + cz * plane.z < plane.offset  ) 
				{
				
					if (clippingTri2 == null) {
						clippingTri2 = createNewTri();
						clippingNormal2 = new Vec3();
					}
				
					clippingTri2.wrapper.vertex.x = ax;
					clippingTri2.wrapper.vertex.y = ay;
					clippingTri2.wrapper.vertex.z = az;
					
					clippingTri2.wrapper.next.vertex.x = bx;
					clippingTri2.wrapper.next.vertex.y = by;
					clippingTri2.wrapper.next.vertex.z = bz;
					
					clippingTri2.wrapper.next.next.vertex.x = cx;
					clippingTri2.wrapper.next.next.vertex.y = cy;
					clippingTri2.wrapper.next.next.vertex.z = cz;
					
					clippingNormal2.x = plane.x;
					clippingNormal2.y = plane.y;
					clippingNormal2.z = plane.z;
					
					ClipMacros.computeMeshVerticesLocalOffsets(clippingTri2, clippingNormal2);
					clippedFace2 = ClipMacros.newPositiveClipFace(clippingTri2, clippingNormal2, plane.offset);
					
					result |= 2;
				}
				
			}
			
			return result;
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
	
	public static function pointInFrustum(frustum:CullingPlane, x:Float, y:Float , z:Float):Bool {
		var plane:CullingPlane = frustum;
		while ( plane != null) {
			if (x * plane.x + y * plane.y + z * plane.z < plane.offset ) {
				return false;
			}
			plane = plane.next;
		}
		return true;
	}
	
}