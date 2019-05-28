package altern.culling;
import altern.terrain.ICuller;

/**
 * ...
 * @author Glidias
 */
class ModFarClipCulling implements ICuller
{

	public function new() 
	{
		
	}
	
	public var frustum:CullingPlane;
	public var distanceMod:Float = 1;
	
	/* INTERFACE altern.terrain.ICuller */
	
	public function cullingInFrustum(culling:Int, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Int 
	{
		var side:Int = 1;
			var plane:CullingPlane = frustum;
			var distanceMod:Float = this.distanceMod;
			while ( plane != null ) {
			
			if ( (culling & side) != 0 ) {
			var offset:Float = side != 2 ? plane.offset : distanceMod;
			if (plane.x >= 0)
			if (plane.y >= 0)
			if (plane.z >= 0) {
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= offset) return -1;
			if (minX*plane.x + minY*plane.y + minZ*plane.z > offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= offset) return -1;
			if (minX*plane.x + minY*plane.y + maxZ*plane.z > offset) culling &= (63 & ~side);
			}
			else
			if (plane.z >= 0) {
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= offset) return -1;
			if (minX*plane.x + maxY*plane.y + minZ*plane.z > offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + minY*plane.y + minZ*plane.z <= offset) return -1;
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z > offset) culling &= (63 & ~side);
			}
			else if (plane.y >= 0)
			if (plane.z >= 0) {
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= offset) return -1;
			if (maxX*plane.x + minY*plane.y + minZ*plane.z > offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + maxY*plane.y + minZ*plane.z <= offset) return -1;
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z > offset) culling &= (63 & ~side);
			}
			else if (plane.z >= 0) {
			if (minX*plane.x + minY*plane.y + maxZ*plane.z <= offset) return -1;
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z > offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + minY*plane.y + minZ*plane.z <= offset) return -1;
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > offset) culling &= (63 & ~side);
			}
			}
			side <<= 1;
			plane = plane.next;
			}
			return culling;
	}
	
}