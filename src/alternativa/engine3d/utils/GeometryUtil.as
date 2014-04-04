package alternativa.engine3d.utils 
{
	import alternativa.engine3d.core.VertexStream;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
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
		
		private static function collectAttributes(geom:Geometry, attributesDict:Vector.<int>, attributesLengths:Vector.<int>):void {
		
			
				

				for each (var stream:VertexStream in geom._vertexStreams) {
					var prev:int = -1;
					var attributes:Array = stream.attributes;
					for each (var attr:int in attributes) {
						attributesLengths[attr]++;
						if (attr == prev) continue;
						attributesDict[attr]++;
						prev = attr;
					}
				}
				
			

			
		}
		
		private static function appendGeometry(geometry:Geometry, geom:Geometry, constantsPerMesh:int):void {
			var stream:VertexStream;
			var i:int, j:int;
			var length:uint = geom._vertexStreams.length;
			var numVertices:int = geom._numVertices;
			for (i = 0; i < length; i++) {
				stream = geom._vertexStreams[i];
				var attributes:Array = geometry._vertexStreams[i].attributes;
				var attribtuesLength:int = attributes.length;
				var destStream:VertexStream = geometry._vertexStreams[i];
				var newOffset:int = destStream.data.length;
				destStream.data.position = newOffset;

				stream.data.position = 0;
				var stride:int = stream.attributes.length*4;
				var destStride:int = destStream.attributes.length*4;
				for (j = 0; j < numVertices; j++) {
					var prev:int = -1;
					for (var k:int = 0; k < attribtuesLength; k++) {
						var attr:int = attributes[k];
						if (attr == ATTRIBUTE) {
							destStream.data.writeFloat(0);
							continue;
						}
						if (attr != prev) {
							stream.data.position = geom._attributesOffsets[attr]*4 + stride*j;
							destStream.data.position = newOffset + geometry._attributesOffsets[attr]*4 + destStride*j;
						}
						destStream.data.writeFloat(stream.data.readFloat());
						prev = attr;
					}
				}

			}
			geometry._numVertices += geom._numVertices;
			
		}
		
		private static function appendGeom(geometry:Geometry, geom:Geometry, constantsPerMesh:int):void {
				
			
				var vertexOffset:uint;
				var i:int, j:int;
				vertexOffset = geometry._numVertices;
				appendGeometry(geometry, geom, constantsPerMesh);
				
				// Copy indexes
			
					
					var indexEnd:uint = geom.numTriangles*3 + 0;
				
					
					for (j = 0; j < indexEnd; j++) {
						geometry._indices.push(geom._indices[j] + vertexOffset);
						
					}
				}

		
		private static function getJointGeometry(geom:Geometry, constantsPerMesh:int):Geometry {
			var geometry:Geometry = new Geometry(0);
		
			var numAttributes:int = 32;
			var attributesDict:Vector.<int> = new Vector.<int>(numAttributes, true);
			var attributesLengths:Vector.<int> = new Vector.<int>(numAttributes, true);
			 collectAttributes(geom, attributesDict, attributesLengths);

			var attributes:Array = [];
			var i:int;

			for (i = 0; i < numAttributes; i++) {
				if (attributesDict[i] > 0) {
					attributesLengths[i] = attributesLengths[i]/attributesDict[i];
				}
			}
			for (i = 0; i < numAttributes; i++) {
				if (Number(attributesDict[i]) == 1) {
					for (var j:int = 0; j < attributesLengths[i]; j++) {
						attributes.push(i);
					}

				}
			}
			attributes.push(ATTRIBUTE);
			geometry.addVertexStream(attributes);
		
			//if (root is Mesh) appendMesh(root as Mesh);
			//collectMeshes(root);
			appendGeom(geometry, geom, constantsPerMesh);
			
			return geometry;
		}
		
		// Borrowed from  MeshSetClonesContainer (based off MeshSet).
		/**
		 * Allows you to convert a single geometry instance into a single geometry cloned-chain with joint ID indices for draw-batching!
		 * @param	geometry	The geometry sample to duplicate
		 * @param	cap		The total amount to duplicate! Give a value higher than  1! Usually the predicted maximum amount of instances per draw batch!)
		 * @param   constantsPerMesh  The amount of constants being used per mesh clone, used to offset the joint indices accordingly to match the correct starting constant register index.
		 */
		public static function createDuplicateGeometry(geometry:Geometry, cap:int, constantsPerMesh:int):Geometry {
			
			geometry  = getJointGeometry(geometry, constantsPerMesh);
	
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