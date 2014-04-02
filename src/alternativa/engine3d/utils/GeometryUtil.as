package alternativa.engine3d.utils 
{
	import alternativa.engine3d.resources.Geometry;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GeometryUtil 
	{
		public static const ATTRIBUTE:uint = 20;
		
		
		
		// Borrowed from  MeshSetClonesContainer (based off MeshSet).
		/**
		 * Allows you to convert a single geometry instance into a single geometry cloned-chain with joint ID indices for draw-batching!
		 * @param	geometry	The geometry sample to duplicate
		 * @param	cap		The total amount to duplicate! Give a value higher than  1! Usually the predicted maximum amount of instances per draw batch!)
		 * @param   constantsPerMesh  The amount of constants being used per mesh clone, used to offset the joint indices accordingly to match the correct starting constant register index.
		 */
		public static function createDuplicateGeometry(geometry:Geometry, cap:int, constantsPerMesh:int):Geometry {
			geometry  = geometry.clone();
			
			//transformProcedure = calculateTransformProcedure(cap);
			//deltaTransformProcedure = calculateDeltaTransformProcedure(cap);
			
			var bytes:ByteArray;
			//throw new Error(geometry.getAttributeValues(VertexAttributes.POSITION))
			// get samples
			var protoJointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
			var protoNumVertices:int = geometry.numVertices;
			
			//_numVertices = protoNumVertices;
			
			var protoByteArrayStreams:Vector.<ByteArray> = new Vector.<ByteArray>();
			var len:int = geometry._vertexStreams.length;
	
			// copy all geometry bytearray data samples for all vertex streams
			for (var i:int = 0; i < len; i++) {
				protoByteArrayStreams[i] = bytes = new ByteArray();
				bytes.endian = Endian.LITTLE_ENDIAN;
				for (var u:int = 0; u < cap; u++) {
					bytes.writeBytes( geometry._vertexStreams[i].data );
				}
			}
			
			// paste geometry data for all the vertex streams
			for (i = 0; i < len; i++) {
				bytes =protoByteArrayStreams[i];
				for (u = 0; u < cap; u++) {
					var data:ByteArray = geometry._vertexStreams[i].data;
					data.position = data.length;
					data.writeBytes(bytes, data.length);
				}
			}
			
			// set number of vertices to match new vertex data size
			geometry._numVertices = protoNumVertices * cap;
		
			var indices:Vector.<uint> = geometry.indices;
			// duplicate indices with offsets
			len = indices.length;
			for (i = 1; i < cap; i++) {
				var indexOffset:int = i * protoNumVertices;
				for (u = 0; u < len; u++) {
					indices.push(indexOffset+ indices[u]);
				}
			}
			geometry.indices = indices;
	
			
			// paste joint attribute values with offsets
			var jointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
			len = protoJointIndices.length;
			var duplicateMultiplier:Number =  constantsPerMesh;
			var totalLen:int = jointIndices.length;
			for (i = len; i < totalLen; i += len) {
				for (u = i; u < i+len; u++) {
					jointIndices[u] += duplicateMultiplier;
				}
				duplicateMultiplier+=  constantsPerMesh;
			}
			geometry.setAttributeValues(ATTRIBUTE, jointIndices);
			
			return geometry;
		}
		
	}

}