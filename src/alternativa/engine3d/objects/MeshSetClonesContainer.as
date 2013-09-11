/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package alternativa.engine3d.objects {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Debug;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.VertexStream;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.protocol.codec.primitive.UIntCodec;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.Dictionary;

	use namespace alternativa3d;

	/**
	 * A modified MeshSet class that allows you to create a dynamic hierachy of meshes (or just a single mesh) (all sharing the same material) which can than be cloned, and than dynamically added  and removed from this container to support batch rendering at varying numbers. Depending on your settings (meshes per surface) and how many meshes are found in your hierachy, you could batch render a certain number of mesh-hierachies at once, saving on your draw calls! The advantage of using this over MeshSet is that this container is supports dynamic cloning, allowing you to add/remove the clones as you wish, as well as reusing a much smaller geometry footprint per batch draw call instead of naively saving entirely static duplicate geometry like what MeshSet does. These 2 differences make it work great with particle systems and crowds. This container isn't recursive, though, and it should not exist under another MeshSet or MeshSetClonesContainer.
	 */
	
	 // TODO: SkinSetClonesContainer...yea!!
	 
	public class MeshSetClonesContainer extends Mesh {
		private var root:Object3D;

		private static const ATTRIBUTE:uint = 20;

		private var surfaceMeshes:Vector.<Vector.<Mesh>> = new Vector.<Vector.<Mesh>>();
		private var surfaceMeshesTris:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();

		public static const MESHES_PER_SURFACE:uint = 40;
		//private var surfaceTransformProcedures:Vector.<Procedure> = new Vector.<Procedure>();
		//private var surfaceDeltaTransformProcedures:Vector.<Procedure> = new Vector.<Procedure>();

		private static var _transformProcedures:Dictionary = new Dictionary();
		private static var _deltaTransformProcedures:Dictionary = new Dictionary();
		
		protected var _material:Material;

		private var meshesPerSurface:uint;
		alternativa3d var clones:Vector.<MeshSetClone> = new Vector.<MeshSetClone>();
		alternativa3d var numClones:int = 0;
		
		public static var CLONE_CLASS:Class = MeshSetClone;
		alternativa3d var cloneClass:Class;
		
		private var orderArray:Vector.<int> = new Vector.<int>();
		private var _numMeshes:int = 0;
		private var _numVertices:int;
		private var outputSurface:Surface;
		private var outputMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var numOutputMeshes:int;
		
		private var currentClone:MeshSetClone;
		private var curCloneMeshIndex:int = 0;
		private var _options:int;
		private var _perBatchClones:int;
		
		protected var constantsPerMesh:int = 0;
		public var objectRenderPriority:int = -1;
		
		/**
		 * Whether to attempt to pack all meshes tightly in the output buffer for ensuring the least amount of drawcalls possible (this could result in slightly larger geometry buffer size)
		 */
		public static const FLAG_PACKWRAP:int = 1;
		/**
		 * Whether to attempt to consider all surfaces (if number of meshes in hierachy exceed MESHES_PER_SURFACE) to detemrine maximum possible duplicate geometry to generate for batch-rendering surfaces. This could result in larger geometry buffer size for such a case, but will help a bit in optimizing drawcalls, otherwise, using this class is pointless.
		 */
		public static const FLAG_CLONESURFACES:int = 2;
		
		/**
		 * Constructor.
		 * @param	root			An unchanging prototype hierachical Object3D reference to use for reference cloning
		 * @param	material		THe material to apply to all meshes
		 * @param	meshesPerSurface (Optional) The number of meshes (transform constants) allowed per surface. Defaulted to MESHES_PER_SURFACE.
		 * @param	cloneClass			(Optional)  Custom MeshSetClone class to use if any. Defaulted to CLONE_CLASS.
		 * @param 	flags			(Optional)  THe clone packing option bitflags to optimize drawcalls (see FLAG_ constants)
		 */
		public function MeshSetClonesContainer(root:Object3D, material:Material, meshesPerSurface:uint = 0, cloneClass:Class = null, flags:int = 1) {
			if (constantsPerMesh  == 0) constantsPerMesh = 3;
			
			this.root = root;
			this.cloneClass = cloneClass != null ? cloneClass : CLONE_CLASS;
			this.meshesPerSurface = meshesPerSurface > 0 ? meshesPerSurface : MESHES_PER_SURFACE;
			this._options = flags;
			
			outputSurface = new Surface();
			outputSurface.object = this;
			outputSurface.material = material;
			
			_material = material;
			calculateGeometry();
			runHierachyOrder(this.root, attemptRegisterMesh);
			
			if ( int(meshesPerSurface/ _numMeshes ) == (meshesPerSurface / _numMeshes )) _options &= ~FLAG_PACKWRAP;
			if ( (_options & FLAG_PACKWRAP) ) {  // TODO: confirm if packwrap is really needed before jumping in!
				duplicateGeometry2();
			}
			else {
				duplicateGeometry();
			}
		}
		
		private function duplicateGeometry():void 
		{
			var totalAllowedFloored:int = (_options & FLAG_CLONESURFACES) ? getMaxPossibleDuplicatesForAllSurfaces() : meshesPerSurface / _numMeshes;
			if (totalAllowedFloored <= 0) totalAllowedFloored = 1;
			_minClonesPerBatch = totalAllowedFloored;
			setupDuplicateGeometry(totalAllowedFloored);
		}
		
		private function getMaxPossibleDuplicatesForAllSurfaces():int {
			var min:int = int.MAX_VALUE;
			for (var i:int = 0; i < surfaceMeshes.length; i++) {
				if (surfaceMeshes[i].length < min) min = surfaceMeshes[i].length;
			}
			return meshesPerSurface / min;
		}
		
		private function duplicateGeometry2():void {
			var numMeshes:int = _numMeshes; 
			var totalAllowed:Number = (_options & FLAG_CLONESURFACES) ? getMaxPossibleDuplicatesForAllSurfaces() : meshesPerSurface / numMeshes;
			_minClonesPerBatch = int(totalAllowed) <= 0 ? 1 : int(totalAllowed);
			if (totalAllowed != int(totalAllowed)) {
				totalAllowed += 2;
			}
			setupDuplicateGeometry( int(totalAllowed) );
		}
		
		private function setupDuplicateGeometry(total:int):void {
			if (total <= 1) return;
			
			var cap:int = total * _numMeshes;
			
			if (cap > meshesPerSurface) {
				cap = meshesPerSurface;
			}
			
			transformProcedure = calculateTransformProcedure(cap);
			deltaTransformProcedure = calculateDeltaTransformProcedure(cap);
			
			var bytes:ByteArray;
			//throw new Error(geometry.getAttributeValues(VertexAttributes.POSITION))
			// get samples
			var protoJointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
			var protoNumVertices:int = geometry.numVertices;
			_numVertices = protoNumVertices;
			var protoByteArrayStreams:Vector.<ByteArray> = new Vector.<ByteArray>();
			var len:int = geometry._vertexStreams.length;
	
			// copy all geometry bytearray data samples for all vertex streams
			for (var i:int = 0; i < len; i++) {
				protoByteArrayStreams[i] = bytes = new ByteArray();
				bytes.endian = Endian.LITTLE_ENDIAN;
				for (var u:int = 0; u < total; u++) {
					bytes.writeBytes( geometry._vertexStreams[i].data );
				}
			}
			
			// paste geometry data for all the vertex streams
			for (i = 0; i < len; i++) {
				bytes =protoByteArrayStreams[i];
				for (u = 0; u < total; u++) {
					var data:ByteArray = geometry._vertexStreams[i].data;
					data.position = data.length;
					data.writeBytes(bytes, data.length);
				}
			}
			
			// set number of vertices to match new vertex data size
			geometry._numVertices = protoNumVertices * total;
		
			var indices:Vector.<uint> = geometry.indices;
			// duplicate indices with offsets
			len = indices.length;
			for (i = 1; i < total; i++) {
				var indexOffset:int = i * protoNumVertices;
				for (u = 0; u < len; u++) {
					indices.push(indexOffset+ indices[u]);
				}
			}
			geometry.indices = indices;
	
			
			// paste joint attribute values with offsets
			var jointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
			len = protoJointIndices.length;
			var duplicateMultiplier:Number = _numMeshes * constantsPerMesh;
			var totalLen:int = jointIndices.length;
			for (i = len; i < totalLen; i += len) {
				for (u = i; u < i+len; u++) {
					jointIndices[u] += duplicateMultiplier;
				}
				duplicateMultiplier+= _numMeshes * constantsPerMesh;
			}
			geometry.setAttributeValues(ATTRIBUTE, jointIndices);
			
			
		}
		
		private function runHierachyOrder(root:Object3D, meshMethod:Function):void 
		{
			if ( root is Mesh) meshMethod(root);
			for (var child:Object3D = root.childrenList; child != null; child = child.next) {
				checkIsMeshRecursive(child, meshMethod);
			}
		}
		
		private function attemptRegisterMesh(mesh:Mesh):void {
			var loc:Vector.<int> = findLocationOfMeshInSurfaceMeshes(mesh);
			if (loc == null) throw new Error("Failed to find mesh!");
			orderArray[(_numMeshes<<1)] = loc[0];
			orderArray[(_numMeshes<<1)+1] = loc[1];
			_numMeshes++;
		}
	
		
		private function checkIsMeshRecursive(child:Object3D, meshMethod:Function):void 
		{
			if ( child is Mesh) meshMethod(child);
			child = child.childrenList;
			while( child!=null) {
				checkIsMeshRecursive(child, meshMethod);
				child = child.next;
			}
		}
		
		private function findLocationOfMeshInSurfaceMeshes(mesh:Object3D):Vector.<int> {
			var len:int = surfaceMeshes.length;
			for (var i:int = 0; i < len; i++) {
				var meshes:Vector.<Mesh> = surfaceMeshes[i];
				var uLen:int = meshes.length;
				for (var u:int = 0; u < uLen; u++) {
					if (meshes[u] === mesh) return new <int>[i,u];
				}
			}
			return null;
		}
		

		public function createClone():MeshSetClone {
			var cloneItem:MeshSetClone = new cloneClass();
			cloneItem.root = root.clone();
			cloneItem.index = -1;
			
			cloneItem.surfaceMeshes = surfaceMeshes.concat();
			var len:int = cloneItem.surfaceMeshes.length;
			for (var i:int = 0; i < len; i++) {
				cloneItem.surfaceMeshes[i]= cloneItem.surfaceMeshes[i].concat();
			}
			
			currentClone = cloneItem;
			curCloneMeshIndex = 0;
			runHierachyOrder(cloneItem.root, assignMeshToClone);
			currentClone = null;
			return cloneItem;
		}
		
		private function assignMeshToClone(mesh:Mesh):void {

			currentClone.surfaceMeshes[orderArray[(curCloneMeshIndex <<1)]][orderArray[(curCloneMeshIndex <<1) + 1]] = mesh;
			curCloneMeshIndex++;
		}
		
		public function addClone(cloneItem:MeshSetClone):void {
			if (cloneItem.index >= 0) throw new Error("Clone item seems to already belong to a container or wasn't freshly created/removed!!");  
			
			cloneItem.index = numClones;
			clones[numClones++] = cloneItem;
		}
		
		public function removeClone(cloneItem:MeshSetClone):void {
			if (cloneItem.index < 0) throw new Error("Clone item seems to already be removed!");
			 
			clones[cloneItem.index] = null;  // nulling reference isn't necessary if pooling clones
			if (cloneItem.index < --numClones) {  
				clones[numClones] = null;  // nulling reference isn't necessary if pooling clones
				clones[cloneItem.index] = clones[numClones];
			}
			cloneItem.index = -1;
			
		}
		alternativa3d function addCloneQuick(cloneItem:MeshSetClone):void {
			cloneItem.index = numClones;
			clones[numClones++] = cloneItem;
		}
		
		alternativa3d function removeCloneQuick(cloneItem:MeshSetClone):void {
			clones[cloneItem.index] = null;  // nulling reference isn't necessary if pooling clones
			if (cloneItem.index < --numClones) {
				clones[numClones] = null;  // nulling reference isn't necessary if pooling clones
				clones[cloneItem.index] = clones[numClones];
			}
			cloneItem.index = -1;
		}
		
        /**
         * @private
         */
		alternativa3d override function calculateVisibility(camera:Camera3D):void {
			super.alternativa3d::calculateVisibility(camera);
			var i:int = numClones;
			while (--i > -1) {
				var root:Object3D = clones[i].root;
				if (root.transformChanged) root.composeTransforms();
				root.localToGlobalTransform.copy(root.transform);
				calculateMeshesTransforms(root);
			}
		}
		
        /**
         * @private
         */
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
		
			var meshesLen:int = surfaceMeshes[_curSurfaceIndex].length;
			var limit:int = _curCloneIndex + _curBatchCount;
	
	
			var offsetNumMeshes:int = _offsetNumMeshes;
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), offsetNumMeshes*constantsPerMesh, 0, 0, 1);
			var count:int = 0;
			
				
				var triCount:int = 0;
			for (var i:int = _curCloneIndex; i < limit; i++) {
				var meshes:Vector.<Mesh> = clones[i].surfaceMeshes[_curSurfaceIndex];
				for (var m:int = offsetNumMeshes; m < meshesLen; m++) {
					var mesh:Mesh = meshes[m];			
					triCount += mesh.geometry.numTriangles;
					setupMesh(drawUnit, i, count * constantsPerMesh, mesh); // hook method for extendability
					count++;
					offsetNumMeshes = 0;
				}
				
			}
		
			// handle pack-fill spill over if any

			if (i  >= numClones) return;
				meshes = clones[i].surfaceMeshes[_curSurfaceIndex];
				for (m = 0; m < _addNumMeshes; m++) {
					mesh = meshes[m];			
					triCount += mesh.geometry.numTriangles;
					setupMesh(drawUnit, -1, count * constantsPerMesh, mesh); // hook method for extendability
					count++;
				}
				
			if (triCount != surface.numTriangles) {
					surface.numTriangles = triCount;
				}
					
		}
		
		protected function setupMesh(drawUnit:DrawUnit, cloneIndex:int, firstRegister:int, mesh:Mesh):void { // hook method for extendability
			drawUnit.setVertexConstantsFromTransform(firstRegister, mesh.localToGlobalTransform);
		}

		private function calculateMeshesTransforms(root:Object3D):void {		
			for (var child:Object3D = root.childrenList; child != null; child = child.next) {
				if (child.transformChanged) child.composeTransforms();
				// Put skin transfer matrix to localToGlobalTransform
				child.localToGlobalTransform.combine(root.localToGlobalTransform, child.transform);
				calculateMeshesTransforms(child);
			}
		}
		
		private var _curCloneIndex:int;
		private var _curSurfaceIndex:int;
		private var _curBatchCount:int;
		private var _minClonesPerBatch:int;
        /**
		 * 
         * @private
         */
		override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
			var addNumTriangles:int;
			var addNumMeshes:int;
			if (geometry == null) return;
			
			var totalClones:int = numClones;
			if (totalClones == 0) return;
		
			
	
			var cloneSurfaces:Boolean = (_options & FLAG_CLONESURFACES) != 0;
			

			var minClonesPerBatch:int = _minClonesPerBatch;
			
			//var i:int = 0;
			for (var i:int = 0; i < _surfacesLength; i++) {
				_curSurfaceIndex = i;
				var surface:Surface = _surfaces[i];
				//transformProcedure = surfaceTransformProcedures[i];  // no longer being used
				//deltaTransformProcedure = surfaceDeltaTransformProcedures[i];
			
				var spillOverMeshes:int = 0;
				 addNumTriangles = 0 ;
				addNumMeshes = 0;
				 _addNumMeshes = 0;
				_offsetNumMeshes = 0;
				var lastNumAddTriangles:int = 0;
				
				var surfaceMeshesLen:int = surfaceMeshes[i].length;
				var packWrap:Boolean = (_options & FLAG_PACKWRAP)!=0 && (cloneSurfaces ? surfaceMeshesLen : _numMeshes) < meshesPerSurface;
				
			
				//var count:int = 0;  // for deubugging
				//var traceStr:String = "";
				for (var c:int = 0; c < totalClones; c += minClonesPerBatch) {
					//count++;
					
					///*  // Pack wrap branch...else should set default above!
					if (packWrap) {
						outputSurface.indexBegin =  lastNumAddTriangles * 3;
						
						var ratio:Number = (meshesPerSurface-spillOverMeshes) / surfaceMeshesLen;
						minClonesPerBatch =  int(ratio);
						//ratio = ratio < 1 ? 0 : ratio;   
						var gotRemainder:Boolean = ratio != int(ratio);
						addNumMeshes = gotRemainder ? meshesPerSurface - minClonesPerBatch*surfaceMeshesLen - spillOverMeshes  : 0;  //(ratio - int(ratio)) * numMeshes
						
						addNumTriangles =  gotRemainder ? getNumTriangles(i, addNumMeshes ) : 0;  
						
						_addNumMeshes =  addNumMeshes;
						minClonesPerBatch+= spillOverMeshes ? 1 : 0;
					
					}
				//*/
				
					_curCloneIndex = c;
					_curBatchCount = totalClones - c;
					_curBatchCount = _curBatchCount > minClonesPerBatch ? minClonesPerBatch : _curBatchCount;
					
					outputSurface.numTriangles = surface.numTriangles * _curBatchCount - lastNumAddTriangles + addNumTriangles;
				
					_material.collectDraws(camera, outputSurface, geometry, lights, lightsLength, useShadow, objectRenderPriority);
				//	traceStr += "\n"+  (surfaceMeshesLen * _curBatchCount-_offsetNumMeshes) + "," + addNumMeshes +  " , " + _offsetNumMeshes + ": "+ _curCloneIndex + ", "+_curBatchCount + " | "+outputSurface.indexBegin + " + "+outputSurface.numTriangles + ", "+surface.numTriangles + " >> " +addNumTriangles;
		
					lastNumAddTriangles = addNumTriangles;
						spillOverMeshes = gotRemainder  ? surfaceMeshesLen - addNumMeshes : 0;
					_offsetNumMeshes = addNumMeshes;

					// Uncomment this if you relying on mouse events!
					//	if (listening) camera.view.addSurfaceToMouseEvents(outputSurface, geometry, transformProcedure);
				};	
				
			}
			
			// Debug
			/*
			if (camera.debug) {
				var debug:int = camera.checkInDebug(this);
				if ((debug & Debug.BOUNDS) && boundBox != null) Debug.drawBoundBox(camera, boundBox, localToCameraTransform);
			}
			*/
		}
		
		
		private var _addNumMeshes:int;
		private var _offsetNumMeshes:int = 0;
		
		private function getNumTriangles(surfaceIndex:int, numMeshes:int):int 
		{
			var count:int = 0;
	
			var counts:Vector.<int> = surfaceMeshesTris[surfaceIndex];
			//var meshes:Vector.<Mesh> = surfaceMeshes[surfaceIndex];
			for (var i:int = 0; i < numMeshes; i++) {
				//count += meshes[i].geometry.numTriangles;
				//if (counts[i] != meshes[i].geometry.numTriangles) throw new Error("MISMATCH!");
				count+=counts[i];
			}
			return count;
		}
		
		private function getOffsetNumTriangles(surfaceIndex:int, numMeshes:int):int 
		{
			var count:int = 0;
	
			var counts:Vector.<int> = surfaceMeshesTris[surfaceIndex];
			var len:int = counts.length;
			for (var i:int = numMeshes; i < len; i++) {
				
				count+=counts[i];
			}
			return count;
		}

		private function calculateGeometry():void {
			geometry = new Geometry(0);
			addSurface(_material, 0, 0);
			var numAttributes:int = 32;
			var attributesDict:Vector.<int> = new Vector.<int>(numAttributes, true);
			var attributesLengths:Vector.<int> = new Vector.<int>(numAttributes, true);
			var numMeshes:Number = collectAttributes(root, attributesDict, attributesLengths);

			var attributes:Array = [];
			var i:int;

			for (i = 0; i < numAttributes; i++) {
				if (attributesDict[i] > 0) {
					attributesLengths[i] = attributesLengths[i]/attributesDict[i];
				}
			}
			for (i = 0; i < numAttributes; i++) {
				if (Number(attributesDict[i])/numMeshes == 1) {
					for (var j:int = 0; j < attributesLengths[i]; j++) {
						attributes.push(i);
					}

				}
			}
			attributes.push(ATTRIBUTE);
			geometry.addVertexStream(attributes);
			if (root is Mesh) appendMesh(root as Mesh);
			collectMeshes(root);
			var surfaceIndex:uint = _surfaces.length - 1;
			var meshes:Vector.<Mesh> = surfaceMeshes[surfaceIndex];
			//surfaceTransformProcedures[surfaceIndex] = calculateTransformProcedure(meshes.length);
			//surfaceDeltaTransformProcedures[surfaceIndex] = calculateDeltaTransformProcedure(meshes.length);
			//throw new Error(numSurfaces);
		}

		private function collectAttributes(root:Object3D, attributesDict:Vector.<int>, attributesLengths:Vector.<int>):int {
			var geom:Geometry;
			var numMeshes:int = 0;
			if (root is Mesh) {
				geom = Mesh(root).geometry;

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
				numMeshes++;
			}

			for (var child:Object3D = root.childrenList; child != null; child = child.next) {
				numMeshes += collectAttributes(child, attributesDict, attributesLengths);
			}
			return numMeshes;
		}

		override public function addSurface(material:Material, indexBegin:uint, numTriangles:uint):Surface {
			surfaceMeshes.push(new Vector.<Mesh>());
			surfaceMeshesTris.push(new Vector.<int>());
			return super.addSurface(material, indexBegin, numTriangles);
		}

		private function collectMeshes(root:Object3D):void {
			for (var child:Object3D = root.childrenList; child != null; child = child.next) {
				if (child is Mesh) {
					appendMesh(child as Mesh);
				}
				collectMeshes(child);
			}
		}
		
		

		private function appendGeometry(geom:Geometry, index:int):void {
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
							destStream.data.writeFloat(index*constantsPerMesh);
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

		private function compareAttribtues(destStream:VertexStream, sourceStream:VertexStream):Boolean {
			if ((destStream.attributes.length - 1) != sourceStream.attributes.length) return false;
			var len:int = sourceStream.attributes.length;
			for (var i:int = 0; i < len; i++) {
				if (destStream.attributes[i] != sourceStream.attributes[i]) return false;
			}
			return true;
		}
		
		

		private function appendMesh(mesh:Mesh):void {
			var surfaceIndex:uint = _surfaces.length - 1;
			var destSurface:Surface = _surfaces[surfaceIndex];
			var meshes:Vector.<Mesh> = surfaceMeshes[surfaceIndex];
		
			var meshTriCounts:Vector.<int> = surfaceMeshesTris[surfaceIndex];
			if (meshes.length >= meshesPerSurface) {
				//surfaceTransformProcedures[surfaceIndex] = calculateTransformProcedure(meshes.length);
				//surfaceDeltaTransformProcedures[surfaceIndex] = calculateDeltaTransformProcedure(meshes.length);
				addSurface(_material, geometry._indices.length, 0);
				surfaceIndex++;
				destSurface = _surfaces[surfaceIndex];
				meshes = surfaceMeshes[surfaceIndex];
				meshTriCounts = surfaceMeshesTris[surfaceIndex];
			//	throw new Error(meshTriCounts + ", "+surfaceIndex);
			}
			meshes.push(mesh);
			var geom:Geometry = mesh.geometry;
			var vertexOffset:uint;
			var i:int, j:int;
			vertexOffset = geometry._numVertices;
			appendGeometry(geom, meshes.length - 1);
		//	trace(surfaceIndex);
			// Copy indexes
			var triCount:int = 0;
			for (i = 0; i < mesh._surfacesLength; i++) {
				var surface:Surface = mesh._surfaces[i];
				var indexEnd:uint = surface.numTriangles*3 + surface.indexBegin;
				triCount += surface.numTriangles;
				destSurface.numTriangles += surface.numTriangles;
				for (j = surface.indexBegin; j < indexEnd; j++) {
					geometry._indices.push(geom._indices[j] + vertexOffset);
				}
			}
		
			meshTriCounts.push( triCount); 
			
		}
		

		private function calculateTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _transformProcedures[numMeshes];
			if (res != null) return res;
			res = _transformProcedures[numMeshes] = new Procedure(null, "MeshSetTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m34 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			res.assignConstantsArray(numMeshes*constantsPerMesh);
			return res;
		}

		private function calculateDeltaTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _deltaTransformProcedures[numMeshes];
			if (res != null) return res;
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "MeshSetDeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		
		public function get material():Material 
		{
			return _material;
		}
		
		public function set material(value:Material):void 
		{
			_material = value;
			outputSurface.material = value;
		}
		
		public function get minClonesPerBatch():int 
		{
			return _minClonesPerBatch;
		}
		
		public function get numMeshes():int 
		{
			return _numMeshes;
		}
	}
}