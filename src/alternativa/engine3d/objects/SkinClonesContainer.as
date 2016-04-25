package alternativa.engine3d.objects 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.compiler.VariableType;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SkinClonesContainer extends Skin
	{
		public static var CLONE_CLASS:Class = SkinClone;
		alternativa3d var cloneClass:Class;
		
		public static const JOINTS_PER_SURFACE:uint = 40;
		private var jointsPerSurface:uint;
		private var _minClonesPerBatch:int;
		private var _numJoints:int;

		alternativa3d var clones:Vector.<SkinClone> = new Vector.<SkinClone>();
		alternativa3d var visibleClones:Vector.<SkinClone>;
		alternativa3d var numClones:int = 0;
		
		
		
		private static var _transformProcedures:Dictionary = new Dictionary();
		private var _curCloneIndex:int;
		private var _curBatchCount:int;
		private var outputSurface:Surface;
		private var flags:int;
		private var _sample:Skin;
		private var protoNumTriangles:int; // Note this will be deciated to surfaceNumTriangles[] in the future
		public var objectRenderPriority:int = -1;
		
		public static const FLAG_GLOBAL_PROCEDURE:int = 1;
		
		// Cashing of procedures on number of influence
		//private static var _deltaTransformProcedures:Vector.<Procedure> = new Vector.<Procedure>(9);
		
		public function SkinClonesContainer(sample:Skin, jointsPerSurface:uint = 0, cloneClass:Class = null, flags:int=0) 
		{
			this.flags = flags;
			
			this.cloneClass = cloneClass || CLONE_CLASS;
			this.jointsPerSurface = jointsPerSurface != 0 ? jointsPerSurface : JOINTS_PER_SURFACE;
			
			super(sample.maxInfluences);
			this.clonePropertiesFrom(sample);
			childrenList = null;
			
			
			_sample = sample;
			
			_x = 0;
			_y = 0;
			_z = 0;
			_rotationX = 0;
			_rotationY = 0;
			_rotationZ = 0;
			_scaleX = 1;
			_scaleY = 1;
			_scaleZ = 1;

			
			if (numSurfaces > 1) throw new Error("Sorry, we don't support >1 material surface for SkinClones at the moment!!");
			
			_numJoints = surfaceJoints[0].length;
			
			outputSurface = new Surface();
			outputSurface.object = this;
			outputSurface.indexBegin = 0;
			outputSurface.material = _surfaces[0].material;
			
			duplicateGeometry();
			boundBox = null;
			
		
			
		}
		
		
		
		private function duplicateGeometry():void 
		{
			///*
			var totalAllowedFloored:int =  jointsPerSurface / _numJoints;
			if (totalAllowedFloored <= 0) totalAllowedFloored = 1;
			_minClonesPerBatch = totalAllowedFloored;
			setupDuplicateGeometry(totalAllowedFloored);
			//*/
			
			/*
			var totalAllowedCeil:int =  Math.ceil( jointsPerSurface / _numJoints);
			_minClonesPerBatch = totalAllowedCeil;
			setupDuplicateGeometry(totalAllowedCeil);
			*/
		}
		
	
		
		
		private function setupDuplicateGeometry(total:int):void {
			if (total <= 1) return;
			
			
			///*
			var cap:int = total * _numJoints;
			
			if (cap > jointsPerSurface) {
				cap = jointsPerSurface;
			}
			//*/
			
			protoNumTriangles = geometry.numTriangles;
			
		
			  // stick to 1 global transform procedure based off jointsPerSurface setting ? 
			transformProcedure = calculateTransformProcedure(maxInfluences, (flags & FLAG_GLOBAL_PROCEDURE ? jointsPerSurface : cap) );
		//	deltaTransformProcedure = calculateDeltaTransformProcedure(maxInfluences);
			
		//	/*
			var bytes:ByteArray;
			//throw new Error(geometry.getAttributeValues(VertexAttributes.POSITION))
			// get samples
		//	var protoJointIndices:Vector.<Number> = geometry.getAttributeValues(ATTRIBUTE);
			var protoNumVertices:int = geometry.numVertices;
			
			
			//_numVertices = protoNumVertices;
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
			
			// TODO: Test shouldn't i start at 1 instead....because geometry is already filled?
			// paste geometry data for all the vertex streams
			for (i = 0; i < len; i++) {
				bytes = protoByteArrayStreams[i];
				var data:ByteArray = geometry._vertexStreams[i].data;
		
				for (u = 1; u < total; u++) {
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
		//	/*
			//len = maxInfluences;
			for (var k:int = 0; k < maxInfluences; k += 2) {
				
				/*
				if (!geometry.hasAttribute(VertexAttributes.JOINTS[k>>1])) {
				//	throw new Error(k);
					break;
				}
				*/
				var jointIndices:Vector.<Number> = geometry.getAttributeValues(VertexAttributes.JOINTS[k>>1]);
				var stride:int = VertexAttributes.getAttributeStride(VertexAttributes.JOINTS[k>>1]);
			//throw new Error(jointIndices);
		
				///*
				len = protoNumVertices * stride;
				var addDupMult:Number =  _numJoints * 3;
				var duplicateMultiplier:Number =addDupMult;
				var totalLen:int = jointIndices.length;
				for (i = len; i < totalLen; i += len) {
					for (u = i; u < i+len; u+=stride) {
						jointIndices[u] += duplicateMultiplier;
						jointIndices[u+2] += duplicateMultiplier;
					}
					duplicateMultiplier+=  addDupMult;
				}
				//*/
				 geometry.setAttributeValues(VertexAttributes.JOINTS[k>>1], jointIndices);
				 
				// throw new Error( getJointIndices( jointIndices.slice( jointIndices.length / 4, jointIndices.length/4+jointIndices.length/4) ,  -10) );
			}
		//	*/
		
				//throw new Error(  geometry.getAttributeValues(VertexAttributes.POSITION).slice(protoNumVertices * 3, protoNumVertices * 3 + protoNumVertices*3) );
		}
		
		private function getJointIndices(values:Vector.<Number>, offset:int=0):Vector.<int> {
			var stuff:Vector.<int>  = new Vector.<int>();
			var len:int = values.length;
			for (var i:int = 0; i < len; i += 4) {
				stuff.push( values[i] / 3 + offset);
			}
			
			return stuff;
		}
		
		public function createClone():SkinClone {
			var cloneItem:SkinClone = new cloneClass();
			cloneItem.root = new Joint();
			

			
		//	cloneItem.root._parent = this;
			cloneItem.index = -1;
			
			var skin:Skin = _sample.clone() as Skin;  // lazy method to grab new set of surfaceJoints, original cloned skin is wasted away	
			
	
			var skinJoint:Joint = new Joint();
			 skinJoint.x = skin._x;
			skinJoint.y = skin._y;
		   skinJoint.z = skin._z;
		   
			skinJoint._scaleX = skin._scaleX;
			skinJoint._scaleY = skin._scaleY;
		   skinJoint._scaleZ = skin._scaleZ;
		   
		   
			skinJoint._rotationX = skin._rotationX;
			skinJoint._rotationY = skin._rotationY;
		   skinJoint._rotationZ = skin._rotationZ;
		   skinJoint.transformChanged = true;
		   
		 //  throw new Error(skinJoint.rotationZ);
		   
		   cloneItem.root.addChild(skinJoint);
		   
		   
			var c:Object3D;
			for (c = skin.childrenList; c != null; c = c.next) {	   
				skinJoint.addChild(c);
			}
			
			
			cloneItem.renderedJoints = skin.surfaceJoints[0];
			return cloneItem;
		}
		
		
	
		
		
		public function addClone(cloneItem:SkinClone):SkinClone {
			//if (cloneItem.index >= 0) throw new Error("Clone item seems to already belong to a container or wasn't freshly created/removed!!");  
			
			cloneItem.index = numClones;
			clones[numClones++] = cloneItem;
			return cloneItem;
		}
		
		/*
		public function addCloneWithCuller(cloneItem:SkinClone):void {
			(culler is IMeshSetClonesContainer) ? (culler as IMeshSetClonesContainer).addClone(cloneItem) : addClone(cloneItem);
		}
		
		public function removeCloneWithCuller(cloneItem:SkinClone):void {
			(culler is IMeshSetClonesContainer) ? (culler as IMeshSetClonesContainer).removeClone(cloneItem) : removeClone(cloneItem);
		}
		*/
		
		public function removeClone(cloneItem:SkinClone):void {
		//	if (cloneItem.index < 0) throw new Error("Clone item seems to already be removed!");
			numClones--;
			//if (clones[cloneItem.index] !== cloneItem) throw new Error("Mismatch! " + clones[cloneItem.index].index + ", " + cloneItem.index);
			var tail:SkinClone = clones[numClones];
			 clones[numClones] = null;
			if (tail!=cloneItem) {  // popback
				clones[cloneItem.index] =   tail;  
				tail.index = cloneItem.index;
			}
			cloneItem.index = -1;
		}
		

		/*  // rip from MeshSetClonesContainer,  to edit for SkinClonesContainer
		alternativa3d override function calculateVisibility(camera:Camera3D):void {
			super.alternativa3d::calculateVisibility(camera);
			numVisibleClones = culler != null ? culler.cull(numClones, clones, visibleClonesCollection, camera, this) : numClones;
			visibleClones = culler != null ? visibleClonesCollection : clones;
			var i:int = numVisibleClones;
			while (--i > -1) {
				var root:Object3D = visibleClones[i].root;
				if (root.transformChanged) root.composeTransforms();
				
				if (root._parent == null) root.localToGlobalTransform.copy(root.transform);
				else {
					if (root._parent.transformChanged) root._parent.composeTransforms();
					root.localToGlobalTransform.combine(root._parent.transform, root.transform);
				}
				
				calculateMeshesTransforms(root);
			}
		}
		*/
		
		/*
		alternativa3d override function calculateVisibility(camera:Camera3D):void {
			super.alternativa3d::calculateVisibility(camera);
			
			var i:int = numClones;
			while (--i > -1) {
				var root:Object3D = clones[i].root;
				if (root.transformChanged) root.composeTransforms();
				
				if (root._parent == null || root._parent === this) root.localToGlobalTransform.copy(root.transform);
				else {
					if (root._parent.transformChanged) root._parent.composeTransforms();
					root.localToGlobalTransform.combine(root._parent.transform, root.transform);
					//throw new Error("A");
				}
				
				calculateMeshesTransforms(root);
			}
		}
		
		private function calculateMeshesTransforms(root:Object3D):void {		
			
			for (var child:Object3D = root.childrenList; child != null; child = child.next) {
				if (child.transformChanged) child.composeTransforms();
				// Put skin transfer matrix to localToGlobalTransform
				child.localToGlobalTransform.combine(root.localToGlobalTransform, child.transform);
				calculateMeshesTransforms(child);
			}
		}
		
	//	*/
		
		
		
		override alternativa3d function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			var i:int, count:int;
			for (i = 0; i < maxInfluences; i += 2) {
				var attribute:int = VertexAttributes.JOINTS[i >> 1];
				drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint" + i.toString()), geometry.getVertexBuffer(attribute), geometry._attributesOffsets[attribute], VertexAttributes.FORMATS[attribute]);
			}

			
			var limit:int = _curCloneIndex + _curBatchCount;
		
			count = 0;
		//	var triCount:int = 0;
			for (i = _curCloneIndex; i < limit; i++) {
				var joints:Vector.<Joint> = visibleClones[i].renderedJoints;
				var jointsLen:int = joints.length;
				var baseI:int = count * _numJoints * 3;
				for (var j:int = 0; j < jointsLen; j++) {
					var joint:Joint = joints[j];			
					drawUnit.setVertexConstantsFromTransform(baseI+j*3 , joint.jointTransform);
			
				}
				count++;
				//triCount += protoNumTriangles;
			}
			//		surface.numTriangles = triCount;
			
		}
	
		
		/**
		 * @private
		 */
		override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
			if (geometry == null) return;

			
			//// Calculate joints matrices  //  this could already done in calculateVisibility?  .. later on when implementing ICuller support for clones
			/*
			for (var child:Object3D = childrenList; child != null; child = child.next) {
				if (child.transformChanged) child.composeTransforms();
				// Write transformToSkin matrix to localToGlobalTransform property
				child.localToGlobalTransform.copy(child.transform);
				if (child is Joint) {
					Joint(child).calculateTransform();
				}
				calculateJointsTransforms(child);
			}
			*/
			
			
			var totalClones:int = numClones; //numVisibleClones;
			visibleClones = clones;
		
			if (totalClones == 0) return;
			
			var minClonesPerBatch:int = _minClonesPerBatch;
		
		
			
			var i:int = totalClones;
			
			while (--i > -1) {  // later this can be transfered to calculateVisibility phase for pre-culling
				var root:Joint = clones[i].root;
				if (root.transformChanged) root.composeTransforms();
				root.localToGlobalTransform.copy(root.transform);
				root.calculateTransform();
				calculateJointsTransforms(root);
			}
			
			
			//  Now only support 1 surface because usually this is the common case for batching skins anyway
			//transformProcedure = surfaceTransformProcedures[0];  // already pre-calculated earlier as highest
			//deltaTransformProcedure = surfaceDeltaTransformProcedures[0];
		//	throw new Error(deltaTransformProcedure);
		
			var surface:Surface = _surfaces[0];
			
			//for (i = 0; i < _surfacesLength; i++) {
			//var surface:Surface = _surfaces[i];
			
		
				
				// Mouse events (i dun need this so i comment i taway)
				//if (listening) camera.view.addSurfaceToMouseEvents(surface, geometry, transformProcedure);
				
				
				for (var c:int = 0; c < totalClones; c += minClonesPerBatch) {
					//count++;
					
				
					
					_curCloneIndex = c;
					
					
					_curBatchCount = totalClones - c;
	
					_curBatchCount = _curBatchCount > minClonesPerBatch ? minClonesPerBatch : _curBatchCount;
					//if (_curBatchCount == 0) throw new Error("AWTAW");
					outputSurface.numTriangles = surface.numTriangles *_curBatchCount;  // surface.numTriangles * _curBatchCount - lastNumAddTriangles + addNumTriangles;
			
					outputSurface.material.collectDraws(camera, outputSurface, geometry, lights, lightsLength, useShadow, objectRenderPriority);
					//	traceStr += "\n"+  (surfaceMeshesLen * _curBatchCount-_offsetNumMeshes) + "," + addNumMeshes +  " , " + _offsetNumMeshes + ": "+ _curCloneIndex + ", "+_curBatchCount + " | "+outputSurface.indexBegin + " + "+outputSurface.numTriangles + ", "+surface.numTriangles + " >> " +addNumTriangles;
		
					/*
					lastNumAddTriangles = addNumTriangles;
					spillOverMeshes = gotRemainder  ? surfaceMeshesLen - addNumMeshes : 0;
					_offsetNumMeshes = addNumMeshes;
					*/
					
					// Uncomment this if you relying on mouse events!
					//	if (listening) camera.view.addSurfaceToMouseEvents(outputSurface, geometry, transformProcedure);
				}
				
				
				
			//}
		}
		
		
		
		// duplicate from skin.as
		private function calculateTransformProcedure(maxInfluences:int, numJoints:int):Procedure {
			var res:Procedure = _transformProcedures[maxInfluences | (numJoints << 16)];
			if (res != null) return res;
			res = _transformProcedures[maxInfluences | (numJoints << 16)] = new Procedure(null, "SkinTransformProcedure");
			var array:Array = [];
			var j:int = 0;
			for (var i:int = 0; i < maxInfluences; i ++) {
				var joint:int = int(i/2);
				if (i%2 == 0) {
					if (i == 0) {
						array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".x]";
						array[j++] = "mul o0, t0.xyz, a" + joint + ".y";
					} else {
						array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".x]";
						array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".y";
						array[j++] = "add o0, o0, t0.xyz";
					}
				} else {
					array[j++] = "m34 t0.xyz, i0, c[a" + joint + ".z]";
					array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".w";
					array[j++] = "add o0, o0, t0.xyz";
				}
			}
			array[j++] = "mov o0.w, i0.w";
			res.compileFromArray(array);
			res.assignConstantsArray(numJoints*3 );
			for (i = 0; i < maxInfluences; i += 2) {
				res.assignVariableName(VariableType.ATTRIBUTE, int(i/2), "joint" + i);
			}
			return res;
		}
		
		
		/*
		private function calculateDeltaTransformProcedure(maxInfluences:int):Procedure {
			var res:Procedure = _deltaTransformProcedures[maxInfluences];
			if (res != null) return res;
			res = new Procedure(null, "SkinDeltaTransformProcedure");
			_deltaTransformProcedures[maxInfluences] = res;
			var array:Array = [];
			var j:int = 0;
			for (var i:int = 0; i < maxInfluences; i ++) {
				var joint:int = int(i/2);
				if (i%2 == 0) {
					if (i == 0) {
						array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".x]";
						array[j++] = "mul o0, t0.xyz, a" + joint + ".y";
					} else {
						array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".x]";
						array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".y";
						array[j++] = "add o0, o0, t0.xyz";
					}
				} else {
					array[j++] = "m33 t0.xyz, i0, c[a" + joint + ".z]";
					array[j++] = "mul t0.xyz, t0.xyz, a" + joint + ".w";
					array[j++] = "add o0, o0, t0.xyz";
				}
			}
			array[j++] = "mov o0.w, i0.w";
			array[j++] = "nrm o0.xyz, o0.xyz";
			res.compileFromArray(array);
			for (i = 0; i < maxInfluences; i += 2) {
				res.assignVariableName(VariableType.ATTRIBUTE, int(i/2), "joint" + i);
			}
			return res;
		}
		*/

	
		
	}

}