package alternativa.engine3d.utils 
{
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Vertex;
	import alternativa.engine3d.core.Wrapper;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Glidias
	 */
	public class ClipMacros
	{
		
		
		public static var transformId:int = 0;
		
		/**
		 * Modify vertex.offset values for each faces' vertices relative to a given plane in camera coordinates.
		 * @param	faceList	The faces to consider
		 * @param	camNormal	The clip normal plane
		 * @param   offset		The plane offset in relation to transformed vertices of face
		 */
		public static function computeMeshVerticesCamOffsets(faceList:Face, camNormal:Vector3D):void {
			transformId++;
			for (var f:Face = faceList; f != null; f = f.processNext) {
				for (var wrapper:Wrapper =  f.wrapper; wrapper != null; wrapper = wrapper.next) {
					var vertex:Vertex = wrapper.vertex;
					if (vertex.transformId != transformId) {
						vertex.offset = vertex.cameraX * camNormal.x + vertex.cameraY * camNormal.y + vertex.cameraZ * camNormal.z;
						vertex.transformId = transformId;
					}
				}
			}
		}
		
		/**
		 * Modify vertex.offset values for each faces' vertices relative to a given plane in camera coordinates.
		 * @param	faceList	The faces to consider
		 * @param	camNormal	The clip normal plane
		 * @param   offset		The plane offset in relation to transformed vertices of face
		 */
		public static function computeMeshVerticesLocalOffsets(faceList:Face, camNormal:Vector3D):void {
			transformId++;
			for (var f:Face = faceList; f != null; f = f.processNext) {
				for (var wrapper:Wrapper =  f.wrapper; wrapper != null; wrapper = wrapper.next) {
					var vertex:Vertex = wrapper.vertex;
					if (vertex.transformId != transformId) {
						vertex.offset = vertex.x * camNormal.x + vertex.y * camNormal.y + vertex.z * camNormal.z;
						vertex.transformId = transformId;
					}
				}
			}
		}
		
		/**
		 * Clones a wrapper deeply, cloning all chained sibling references too.
		 * @param	wrapper
		 * @return  The cloned wrapper list
		 */
		private function deepCloneWrapper(wrapper:Wrapper):Wrapper { // inline
			var wrapperClone:Wrapper = wrapper.create();
			wrapperClone.vertex = wrapper.vertex;

			var w:Wrapper = wrapper.next;
			var tailWrapper:Wrapper = wrapperClone;
			while (w != null) {
				var wClone:Wrapper = w.create();
				wClone.vertex = w.vertex;
				tailWrapper.next = wClone;
				tailWrapper = wClone;
				w = w.next;
			}
			return wrapperClone;
		}
		
		public static function isValidFaceList(list:Face, throwError:Boolean = false):Boolean {
			for (var f:Face = list; f != null; f = f.next) {
				isValidFace(f, throwError);
			}
			
			return true;
		}
		
		public static function calculateBestSequenceAndNormal(list:Face):void {
			for (var f:Face = list; f != null; f = f.next) {
				f.calculateBestSequenceAndNormal();
			}

		}
		
		
		public static function isValidFace(face:Face, throwError:Boolean = false):Boolean {
			if (face.wrapper == null) {
				if (throwError) throw new Error("No wrapper found for face:" + face);
				return false;
			}
			var count:int = 0;
			for (var wrapper:Wrapper =  face.wrapper; wrapper != null; wrapper = wrapper.next) {
				var vertex:Vertex = wrapper.vertex;		
				if (vertex == null) {
					if (throwError) throw new Error("Missing vertex for wrapper at:" + count);
					return false;
				}
				count++;		
			}
			if (count < 3)  {
				if (throwError) throw new Error("Not enough vertices to form valid face! Vertex Count:" + count);
				return false;
			}
			
			return true;
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
		public static function getClippedVerticesForFace(face:Face, normal:Vector3D, offset:Number, tailWrapper:Wrapper, wrapperClone:Wrapper):Wrapper {
			// continue with clipping (iterate through all vertices)
			var nextWrapper:Wrapper;
			var headWrapper:Wrapper; 	// the very first valid vertex wrapper found
			
			var w:Wrapper, wClone:Wrapper;
			
			var a:Vertex = tailWrapper.vertex;	 
			var ao:Number = a.offset; 			 
			var bo:Number;   			 		 
			var b:Vertex;  						 
			var ratio:Number;
			var v:Vertex;						// new created vertex
			
			for (w = wrapperClone; w != null; w = nextWrapper) {
				nextWrapper = w.next;
				b = w.vertex;
				bo = b.offset;
				
				if (bo > offset && ao <= offset || bo <= offset && ao > offset) { // diff plane sides
					v = b.create();
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
								
					wClone = w.create();
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
			}
			
			return headWrapper;
		}
		
		/**
		 * Updates an existing cloned face to be clipped against a plane. 
		 * @param	face
		 * @param	normal	Plane normal
		 * @param	offset	Plane offset
		 */
		public static function updateClipFace(face:Face, normal:Vector3D, offset:Number):void {
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
		public static function newPositiveClipFace(face:Face, normal:Vector3D, offset:Number):Face  
		{
			// Prepare cloned face
			var clipFace:Face = face.create();
			//clipFace.material = face.material;
			clipFace.offset = face.offset;
			clipFace.normalX = face.normalX;
			clipFace.normalY = face.normalY;
			clipFace.normalZ = face.normalZ;

			
			// deepCloneWrapper() inline
			var wrapper:Wrapper = face.wrapper;
			var wrapperClone:Wrapper = wrapper.create();
			wrapperClone.vertex = wrapper.vertex;

			var w:Wrapper = wrapper.next;
			var tailWrapper:Wrapper = wrapperClone;
			var wClone:Wrapper;
			while (w != null) {
				wClone = w.create();
				wClone.vertex = w.vertex;
				tailWrapper.next = wClone;
				tailWrapper = wClone;
				w = w.next;
			}
			
			// get new wrapper of clipped vertices
			clipFace.wrapper =  getClippedVerticesForFace(face, normal, offset, tailWrapper, wrapperClone);
		
			return clipFace;
		}
		
		public static function faceNeedsClipping(face:Face, offset:Number):Boolean {
					// First 3 vertices quick-check with their precomputed plane offset values
					var r:Wrapper = face.wrapper;
					var result:Boolean = false;
					var w:Wrapper;
					var a:Vertex = r.vertex; r = r.next;  
					var b:Vertex = r.vertex; r = r.next; 
					var c:Vertex = r.vertex; r = r.next;
					var ao:Number = a.offset;
					var bo:Number = b.offset;
					var co:Number = c.offset;
					w = null;
					
					if (ao <= offset && bo <= offset && co <= offset) { 	  // possible all out..
						for (w = r; w != null; w = w.next) {  // any remaining vertices?
							if (w.vertex.offset > offset) { 
								// still need to clip.
								result = true;
								break;
							}
						}
						if (w == null) { 	
							//  remove off from process list since it's completely hidden in negative space
							result = false;
						}	
					}
					
					else if (ao > offset && bo > offset && co > offset  ) {	// possible all in...
						
						for (w = r; w != null; w = w.next) {    // any remaining vertices?
							if (w.vertex.offset <= offset) { 
								// still need to clip.
								result = true;
								break;
							}
						}
						// no clipping required for this plane
						if ( w==null) {
						
							result = false;
								
						}
					}
					else result = true;
					
					return result;
		}
		
	}
	

}