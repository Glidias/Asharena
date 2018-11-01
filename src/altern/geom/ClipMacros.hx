package altern.geom;
import altern.culling.CullingPlane;
import util.geom.Vec3;

/**
 * ...
 * @author Glidias
 */
class ClipMacros
{
	public static var DUMMY_VECTOR:Vec3 = new Vec3();
		
	public static var transformId:Int = 0;

	public function new() 
	{
		
	}
	
	/**
	 * Modify vertex.offset values for each faces' vertices relative to a given plane in camera coordinates.
	 * @param	faceList	The faces to consider
	 * @param	camNormal	The clip normal plane
	 * @param   offset		The plane offset in relation to transformed vertices of face
	 */
	public static function computeMeshVerticesLocalOffsets(faceList:Face, camNormal:Vec3, camOffset:Float):Void {
		var wrapper:Wrapper;
		var f:Face;
		transformId++;
		f = faceList;
		while (f != null) {
			wrapper =  f.wrapper;
			while (wrapper != null) {
				var vertex:Vertex = wrapper.vertex;
				if (vertex.transformId != transformId) {
					vertex.offset = vertex.x * camNormal.x + vertex.y * camNormal.y + vertex.z * camNormal.z + camOffset;
					vertex.transformId = transformId;
				}
				
				wrapper = wrapper.next;
			}
			
			f = f.processNext;
		}
	}
	
	/**
	 * Clones a wrapper deeply, cloning all chained sibling references too.
	 * @param	wrapper
	 * @return  The cloned wrapper list
	 */
	private function deepCloneWrapper(wrapper:Wrapper):Wrapper { // inline
		var wrapperClone:Wrapper = Wrapper.create();
		wrapperClone.vertex = wrapper.vertex;

		var w:Wrapper = wrapper.next;
		var tailWrapper:Wrapper = wrapperClone;
		while (w != null) {
			var wClone:Wrapper = Wrapper.create();
			wClone.vertex = w.vertex;
			tailWrapper.next = wClone;
			tailWrapper = wClone;
			w = w.next;
		}
		return wrapperClone;
	}
	
	
	/**
	 * Modifies wrapper vertex ordering according to clip plane
	 * @param	face
	 * @param	normal	 
	 * @param	offset				
	 * @param	tailWrapper		Tail of vertex list to compare from at the beginning of iteration
	 * @param	wrapperClone	Header of vertex list to start iterating from
	 * @return  A wrapper list of vertices containing the clipped vertices
	 */
	public static function getClippedVerticesForFace(face:Face, normal:Vec3, offset:Float, tailWrapper:Wrapper, wrapperClone:Wrapper):Wrapper {
		// continue with clipping (iterate through all vertices)
		var nextWrapper:Wrapper;
		var headWrapper:Wrapper = null;	// the very first valid vertex wrapper found
		
		var w:Wrapper, wClone:Wrapper;
		
		var a:Vertex = tailWrapper.vertex;	 
		var ao:Float = a.offset; 			 
		var bo:Float;   			 		 
		var b:Vertex;  						 
		var ratio:Float;
		var v:Vertex;						// new created vertex
		
		w = wrapperClone;
		while (w != null) {
			nextWrapper = w.next;
			b = w.vertex;
			bo = b.offset;
			
			if (bo > offset && ao <= offset || bo <= offset && ao > offset) { // diff plane sides
				v = Vertex.create();
				//this.lastVertex.next = v;
				//this.lastVertex = v;
							
				ratio = (offset - ao)/(bo - ao);
				v.cameraX = a.cameraX + (b.cameraX - a.cameraX)*ratio;
				v.cameraY = a.cameraY + (b.cameraY - a.cameraY)*ratio;
				v.cameraZ = a.cameraZ + (b.cameraZ - a.cameraZ)*ratio; 
				v.x = a.x + (b.x - a.x)*ratio;
				v.y = a.y + (b.y - a.y)*ratio;
				v.z = a.z + (b.z - a.z)*ratio;
				//v.u = a.u + (b.u - a.u)*ratio;
				//v.v = a.v + (b.v - a.v) * ratio;
				
				//v.offset = a.offset + (b.offset - a.offset) * ratio;  // why was this commented away?
							
				wClone = Wrapper.create();
				wClone.vertex = v;
				if (headWrapper != null) tailWrapper.next = wClone; 
				else headWrapper = wClone;
				tailWrapper = wClone;
			}
			
			if (bo > offset) { // current beta w should be appended as well as it's going from back to front
				if (headWrapper != null) tailWrapper.next = w; 
				else headWrapper = w;
				tailWrapper = w;
				w.next = null;
			} 
			else {		// current beta w should be culled as it's going from front to back.
				w.vertex = null;	
				w.next = Wrapper.collector;
				Wrapper.collector = w;
			}
			
			a = b;		// set tail alpha to current beta before continuing
			ao = bo;
			
			w = nextWrapper;
		}
		
		return headWrapper;
	}
	
	/**
	 * Updates an existing cloned face to be clipped against a plane. 
	 * @param	face
	 * @param	normal	Plane normal
	 * @param	offset	Plane offset
	 */
	public static function updateClipFace(face:Face, normal:Vec3, offset:Float):Void {
		// Since face isn't a circular linked list with length property, need to find tail vertex
		// again by iteration
		var w:Wrapper = face.wrapper;
		var tailWrapper:Wrapper = w;
		while (w != null) {
			tailWrapper = w;
			w = w.next;
		}
		face.wrapper = getClippedVerticesForFace(face, normal, offset, tailWrapper, face.wrapper);
	}
	
	/**
	 * Creates a new clip face at the positive side of a given clip plane.
	 * @param	face	An existing face
	 * @param	normal	The clip plane normal
	 * @param	offset	The clip plane offset to test against
	 * @return	A new positive clip face
	 */
	public static function newPositiveClipFace(face:Face, normal:Vec3, offset:Float):Face  
	{
		// Prepare cloned face
		var clipFace:Face = Face.create();
		//clipFace.material = face.material;
		clipFace.offset = face.offset;
		clipFace.normalX = face.normalX;
		clipFace.normalY = face.normalY;
		clipFace.normalZ = face.normalZ;

		
		// deepCloneWrapper() inline
		var wrapper:Wrapper = face.wrapper;
		var wrapperClone:Wrapper = Wrapper.create();
		wrapperClone.vertex = wrapper.vertex;

		var w:Wrapper = wrapper.next;
		var tailWrapper:Wrapper = wrapperClone;
		var wClone:Wrapper;
		while (w != null) {
			wClone = Wrapper.create();
			wClone.vertex = w.vertex;
			tailWrapper.next = wClone;
			tailWrapper = wClone;
			w = w.next;
		}
		
		// get new wrapper of clipped vertices
		clipFace.wrapper =  getClippedVerticesForFace(face, normal, offset, tailWrapper, wrapperClone);
	
		return clipFace;
	}
	
	public static function getOverlapClipFace(clipperFace:Face, face:Face):Face {
		var v:Vertex;
		var w:Wrapper;
		var ax:Float;
		var ay:Float;
		var az:Float;
		var bx:Float;
		var by:Float;
		var bz:Float;
		var negativeFace:Face = null;
		ax = clipperFace.normalX;
		ay = clipperFace.normalY;
		az = clipperFace.normalZ;
		var inputNorm:Vec3 = ClipMacros.DUMMY_VECTOR;
		w = clipperFace.wrapper;
		while (w != null) {
			v = w.vertex;
			var v2:Vertex = w.next != null ? w.next.vertex : clipperFace.wrapper.vertex;
			bx = v2.x - v.x;
			by = v2.y - v.y;
			bz = v2.z - v.z;
			var d:Float = 1 / Math.sqrt(bx * bx + by * by + bz * bz);
			bx *= d;
			by *= d;
			bz *= d;
			inputNorm.x = bz*ay - by*az;
			inputNorm.y = bx*az - bz*ax;
			inputNorm.z = by * ax - bx * ay;
			
			var offset:Float = v.x * inputNorm.x + v.y * inputNorm.y + v.z * inputNorm.z;

				
			ClipMacros.computeMeshVerticesLocalOffsets(face, inputNorm, offset);
			
			if (negativeFace == null) negativeFace = ClipMacros.newPositiveClipFace(face, inputNorm, offset);
			else ClipMacros.updateClipFace(face, inputNorm, offset);
			if (negativeFace.wrapper == null) negativeFace = null;
			face = negativeFace;
			if (face == null) {
				// face happens to lie completely on the outside of a plane
				//gotExit = true;
				break;  
			}
				
			w = w.next;
		}
		
		if (negativeFace != null) {
			return negativeFace;
			//return "Negative: "+gotExit + ":"+ negativeFace.wrapper + "="+count + "/"+pCount;
		}
		
		return null;
	}
		
		
	public static function clipWithPlaneList(planeList:CullingPlane, disposableFace:Face, clipMask:Int=0):Face {
		var p:CullingPlane;
		var f:Face = disposableFace;
		var negativeFace:Face = null;
		//var count:int = 0;
		//var gotExit:Boolean = false;
		//var pCount:int = 0 ;
		//for (p = planeList; p != null; p = p.next) {
		//	pCount++;
			
		//}
		
		var inputNorm:Vec3 = ClipMacros.DUMMY_VECTOR;
		var count:Int = 0;
		p = planeList;
		while (p != null) {
			if ( (clipMask & (1<<count))!=0 ) {
				count++;
				
				p = p.next;
				continue;
			}
			inputNorm.x = -p.x;
			inputNorm.y = -p.y;
			inputNorm.z = -p.z;
			var offset:Float = -p.offset;
			
			ClipMacros.computeMeshVerticesLocalOffsets(f, inputNorm, offset);
			
			if (negativeFace == null) negativeFace = ClipMacros.newPositiveClipFace(f, inputNorm, offset);
			else ClipMacros.updateClipFace(f, inputNorm, offset);
			if (negativeFace.wrapper == null) negativeFace = null;
			f = negativeFace;
			if (f == null) {
				break;  
			}
			count++;
			
			p = p.next;
		}
		
		if (negativeFace != null) {
			return negativeFace;
		}
		else {
		}
		
		return null;
	}
		
	public static function disposeTotalAreaIntersections(faceList:Face):Float 
	{
		// Retrieves accumulated area of intersections between polygons (pairwise) 
		var accum:Float = 0;
		var lastFace:Face = null;
		var f:Face = faceList;
		while (f != null) {
			var p:Face = f.next;
			while (p != null) {
				if (f.overlapsOther2D(p)) {
					var overlapFace:Face = ClipMacros.getOverlapClipFace(f, p);
					if (overlapFace != null) {
						accum += overlapFace.getArea();
						overlapFace.destroy();
						overlapFace.next = Face.collector;
						Face.collector = faceList;
					}
				}	
				
				p = p.next;
			}
			lastFace = f;
			
			f = f.next;
		}
		lastFace.next = Face.collector;
		Face.collector = faceList;
		return accum;
	}
	
}