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
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SkinClonesContainer extends Skin
	{
		private var root:Object3D;
		private var rootSkin:Skin;
		
		public static var CLONE_CLASS:Class = SkinClone;
		alternativa3d var cloneClass:Class;
		
		public static const JOINTS_PER_SURFACE:uint = 40;
		private var jointsPerSurface:uint;
		
		private var orderArray:Vector.<int> = new Vector.<int>();
		
		private var _numJoints:int = 0;
		private var _minClonesPerBatch:int = 0;
		
		// key = maxInfluences | numJoints << 16
		private static var _transformProcedures:Dictionary = new Dictionary();


		alternativa3d var clones:Vector.<SkinClone> = new Vector.<SkinClone>();
		alternativa3d var numClones:int = 0;
		
		public function SkinClonesContainer(root:Object3D, jointsPerSurface:uint = 0, cloneClass:Class = null) 
		{
			this.root = root;
			this.cloneClass = cloneClass || CLONE_CLASS;
			this.jointsPerSurface = jointsPerSurface != 0 ? jointsPerSurface : JOINTS_PER_SURFACE;
			
			
			super(rootSkin.maxInfluences);
			this.clonePropertiesFrom(rootSkin);
			calculateNumJoints();
			
			duplicateGeometry();
		}
		
		private function calculateNumJoints():void 
		{
			var count:int = 0;
			var len:int = surfaceJoints.length; 
			for (var i:int = 0; i < len; i++) {
				count += surfaceJoints[i].length;
			}
			_numJoints = count;
		}
		
		private function duplicateGeometry():void 
		{
			var totalAllowedFloored:int =  jointsPerSurface / _numJoints;
			if (totalAllowedFloored <= 0) totalAllowedFloored = 1;
			_minClonesPerBatch = totalAllowedFloored;
			setupDuplicateGeometry(totalAllowedFloored);
		}
		
		private function setupDuplicateGeometry(total:int):void {
			if (total <= 1) return;
			
			var cap:int = total * _numJoints;
			
			if (cap > jointsPerSurface) {
				cap = jointsPerSurface;
			}
			
			transformProcedure = calculateTransformProcedure(cap, _numJoints );
		//	deltaTransformProcedure = calculateDeltaTransformProcedure(maxInfluences);
			
			/*
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
			var duplicateMultiplier:Number = _numMeshes * 3;
			var totalLen:int = jointIndices.length;
			for (i = len; i < totalLen; i += len) {
				for (u = i; u < i+len; u++) {
					jointIndices[u] += duplicateMultiplier;
				}
				duplicateMultiplier+= _numMeshes * 3;
			}
			geometry.setAttributeValues(ATTRIBUTE, jointIndices);
			*/
			
		}
		
		public function get minClonesPerBatch():int 
		{
			return _minClonesPerBatch;
		}
		
		alternativa3d override function calculateVisibility(camera:Camera3D):void {
			super.alternativa3d::calculateVisibility(camera);
			var i:int = numClones;
			while (--i > -1) {
				var root:Object3D = clones[i].root;
				if (root.transformChanged) root.composeTransforms();
				root.localToGlobalTransform.copy(root.transform);
				calculateJointsTransforms(root);
			}
		}
		
		
	
		
		/**
		 * @private
		 */
		override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
			if (geometry == null) return;

			for (var i:int = 0; i < _surfacesLength; i++) {
				var surface:Surface = _surfaces[i];
				
				//transformProcedure = surfaceTransformProcedures[i];  // already pre-calculated earlier as highest
				deltaTransformProcedure = surfaceDeltaTransformProcedures[i];
				
				
				// TODO: batch darawing procedure for clones
				if (surface.material != null) surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);

				
				// Mouse events
				//if (listening) camera.view.addSurfaceToMouseEvents(surface, geometry, transformProcedure);
			}
		}

		/**
		 * @private 
		 */
		override alternativa3d function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			var i:int, count:int;
			for (i = 0; i < maxInfluences; i += 2) {
				var attribute:int = VertexAttributes.JOINTS[i >> 1];
				drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint" + i.toString()), geometry.getVertexBuffer(attribute), geometry._attributesOffsets[attribute], VertexAttributes.FORMATS[attribute]);
			}
			var surfaceIndex:int = _surfaces.indexOf(surface);  //cursurface index
			var joints:Vector.<Joint> = surfaceJoints[surfaceIndex]; // current skin's surfaceJoints
			for (i = 0,count = joints.length; i < count; i++) {
				var joint:Joint = joints[i];
				drawUnit.setVertexConstantsFromTransform(i*3, joint.jointTransform);
			}
		}
		
		//override alternativa3d function updateBoundBox(bound
		
		// duplicate off Skin class
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
				res.assignConstantsArray(numJoints*3);
				for (i = 0; i < maxInfluences; i += 2) {
				res.assignVariableName(VariableType.ATTRIBUTE, int(i/2), "joint" + i);
				}
				return res;
				}

			


		
	}

}