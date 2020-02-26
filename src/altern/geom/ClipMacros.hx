package altern.geom;
import altern.culling.CullingPlane;
import util.geom.Vec3;

/**
 * ...
 * @author Glidias
 */
#if alternExpose @:expose #end
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
	 */
	public static function computeMeshVerticesLocalOffsets(faceList:Face, camNormal:Vec3):Void {
		var wrapper:Wrapper;
		var f:Face;
		transformId++;
		f = faceList;
		while (f != null) {
			wrapper =  f.wrapper;
			while (wrapper != null) {
				var vertex:Vertex = wrapper.vertex;
				if (vertex.transformId != transformId) {
					vertex.offset = vertex.x * camNormal.x + vertex.y * camNormal.y + vertex.z * camNormal.z;
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
	
	public static function calculateFaceCoordinates2(faceList:Face, faceReference:Face):Void {
		var calculateId:Int = ++ClipMacros.transformId;
		
		var origin:Vertex = faceReference.wrapper.next.vertex;
		var top:Vertex = faceReference.wrapper.vertex;
		var right:Vertex = faceReference.wrapper.next.next.vertex;
		
		
		// axes
		var topX:Float = top.x - origin.x;
		var topY:Float = top.y - origin.y;
		var topZ:Float = top.z - origin.z;
		var rightX:Float = right.x - origin.x;
		var rightY:Float = right.y - origin.y;
		var rightZ:Float = right.z - origin.z;
		
		var d:Float;
		var topD:Float = Math.sqrt(topX * topX + topY * topY + topZ * topZ);
		d = 1 / topD;
		
		topX *= d;
		topY *= d;
		topZ *= d;
		
		var rightD:Float = Math.sqrt(rightX * rightX + rightY * rightY + rightZ * rightZ);
		d = 1 / rightD;
		//Log.trace("RIGHT" + "::"+rightD);
		rightX *= d;
		rightY *= d;
		rightZ *= d;
		
	
		var vx:Float;
		var vy:Float;
		var vz:Float;
		
		var f:Face = faceList;
		while (f != null) {
			var w:Wrapper = f.wrapper;
			while ( w != null) {
				var v:Vertex = w.vertex;
				if (v.transformId != calculateId) {
					v.transformId = calculateId;
					vx = v.x - origin.x;
					vy = v.y - origin.y;
					vz = v.z - origin.z;
					v.cameraX = vx * rightX + vy * rightY + vz * rightZ;
					v.cameraY = vx * topX + vy * topY + vz * topZ;
					/*
					if (v.cameraX > rightD+1e6) {
						trace("Exceeded x bounds by:" + (v.cameraX - rightD) );
					}
					if (v.cameraY > topD+1e6) {
						trace("Exceeded y bounds by:" + (v.cameraY - topD) );
					}
					*/
					//Log.trace(v.cameraX + ", " + v.cameraY + ":: "+ (vx*faceReference.normalX + vy * faceReference.normalY + vz*faceReference.normalZ) );
					
				}
				w = w.next;
			}
			f = f.next;
		}
	}
	
	public static function calculateFaceCoordinates(faceList:Face, top:Vec3, right:Vec3, origin:Vec3):Void {
		var calculateId:Int = ++ClipMacros.transformId;

		// axes
		var topX:Float = top.x;
		var topY:Float = top.y;
		var topZ:Float = top.z;
		var rightX:Float = right.x;
		var rightY:Float = right.y;
		var rightZ:Float = right.z;

		var vx:Float;
		var vy:Float;
		var vz:Float;
		
		var f:Face = faceList;
		while (f != null) {
			var w:Wrapper = f.wrapper;
			while (w != null) {
				var v:Vertex = w.vertex;
				if (v.transformId != calculateId) {
					v.transformId = calculateId;
					vx = v.x - origin.x;
					vy = v.y - origin.y;
					vz = v.z - origin.z;
					v.cameraX = vx * rightX + vy * rightY + vz * rightZ;
					v.cameraY = vx * topX + vy * topY + vz * topZ;
					/*
					if (v.cameraX > rightD+1e6) {
						Log.trace("Exceeded x bounds by:" + (v.cameraX - rightD) );
					}
					if (v.cameraY > topD+1e6) {
						Log.trace("Exceeded y bounds by:" + (v.cameraY - topD) );
					}
					*/
					//Log.trace(v.cameraX + ", " + v.cameraY + ":: "+ (vx*faceReference.normalX + vy * faceReference.normalY + vz*faceReference.normalZ) );
					
				}
				w = w.next;
			}
			f = f.next;
		}
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
				
			ClipMacros.computeMeshVerticesLocalOffsets(face, inputNorm);
			
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
			
			ClipMacros.computeMeshVerticesLocalOffsets(f, inputNorm);
			
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
		/*
		else {
		}
		*/
		
		return null;
	}
	
	
	/*	// This method is disproved
	public static function disposeTotalAreaIntersections(faceList:Face, limit:Float=3.40282346638528e+38):Float 
	{
		// Retrieves accumulated area of intersections between polygons (pairwise) 
		var accum:Float = 0;
		var lastFace:Face = null;
		var f:Face = faceList;
		var limitReached:Bool = false;
		while (f != null) {
			var p:Face = f.next;
			while (p != null && !limitReached) {
				if (f.overlapsOther2D(p)) {
					var overlapFace:Face = ClipMacros.getOverlapClipFace(f, p);
					if (overlapFace != null) {
						accum += overlapFace.getArea();
						overlapFace.destroy();
						overlapFace.next = Face.collector;
						overlapFace.destroy();
						Face.collector = overlapFace;
						limitReached = accum >= limit;
						if (limitReached) {
							accum = limit;
							break;
						}
					}
				}	
				p = p.next;
			}
			lastFace = f;
			f.destroy();
			f = f.next;
		}
		lastFace.next = Face.collector;
		Face.collector = faceList;
		return accum;
	}
	*/
	
}