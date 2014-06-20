package alternativa.a3d.objects 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.alternativa3d;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	use namespace alternativa3d;
	/**
	 * Yes,  ~120 arrows/projectiles per draw call! Let thy arrows blot the sun!!
	 * We determine arrow position and orientation, from velocity, offset and time...within GPU itself.
	 * @author Glenn Ko
	 */
	public class ArrowLobMeshSet extends Mesh
	{
		private var batchAmount:int;
		public var _maxProjectileTravelTime:Number;
		public var _maxProjectileTravelTimeMult:Number;
		private var sampleNumTris:int;
		private static var BATCH_AMOUNT:int = 120;
		
		private static var _transformProcedures:Dictionary = new Dictionary();
		private static var _deltaTransformProcedures:Dictionary = new Dictionary();
		
		public var toUpload:Vector.<Number> = new Vector.<Number>();

		public var total:int = 0;
		private static const ATTRIBUTE:int = GeometryUtil.ATTRIBUTE;
		private var constantsPerMesh:int;
		
		private var gravity:Number = 266;
		public function setGravity(val:Number):void {
			gravity = val;
		}
		
		public function ArrowLobMeshSet(arrowGeometry:Geometry, material:Material, maxProjectileTravelTime:Number=10) 
		{
			super();
			this.maxProjectileTravelTime = maxProjectileTravelTime;
			batchAmount = BATCH_AMOUNT;
			sampleNumTris = arrowGeometry.numTriangles;
			constantsPerMesh = 1;
			geometry = GeometryUtil.createDuplicateGeometry(arrowGeometry, batchAmount, constantsPerMesh);
			
			mySurface = addSurface( material, 0, sampleNumTris*total  );
			
			transformProcedure = calculateTransformProcedure(batchAmount);
		//	deltaTransformProcedure = calculateDeltaTransformProcedure(batchAmount);
			
			this.maxProjectileTravelTime = maxProjectileTravelTime;
			
			
			
			boundBox = null;
		}
		

		private var _remainingTotal:int;
		private var _toUploadAmount:int;
		
			alternativa3d function setVertexConstantsFromVector(drawUnit:DrawUnit, firstRegister:int, data:Vector.<Number>, numRegisters:int, fromParticleIndex:int):void {
			
			if (uint(firstRegister) > (128 - numRegisters)) throw new Error("Register index " + firstRegister + " is out of bounds.");
			var vertexConstants:Vector.<Number> = drawUnit.vertexConstants;
			fromParticleIndex *= (constantsPerMesh<<2);
			
			var offset:int = firstRegister << 2;
			if (firstRegister + numRegisters > drawUnit.vertexConstantsRegistersCount) {
				drawUnit.vertexConstantsRegistersCount = firstRegister + numRegisters;
				vertexConstants.length = drawUnit.vertexConstantsRegistersCount << 2;
			}
			
			for (var i:int = fromParticleIndex, len:int = fromParticleIndex + (numRegisters << 2); i < len; i++) {
				vertexConstants[offset] = data[i];
				offset++;
			}
		}
		
		
		
		private var particleDrawCount:int = 0;
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
	
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), -.5 * gravity, 0, gravity, _maxProjectileTravelTime);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cUp"), 0, 0, 1, 0);
			
			//drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
			
	
			setVertexConstantsFromVector( drawUnit, 0, toUpload, _toUploadAmount*constantsPerMesh, particleDrawCount);
	
			//throw new Error(e.message + ":"+_toUploadAmount + ", " + toUploadData.length);
	
	
			
			//if (triCount != surface.numTriangles) {
				surface.numTriangles = _toUploadAmount * sampleNumTris;
			//}
					
			particleDrawCount += _toUploadAmount;
		}
		
		
		// TODO: This should be factored out to a different manager
		public function update(time:Number):void {
			
			
			var dt:Number = time * _maxProjectileTravelTimeMult;
			for (var i:int = 0; i < total; i++) {
				var c:int = (i << 2);
				var w:Number = toUpload[c + 3];
				var whole:int = int(w);
				
				var frac:Number = w - whole;
				frac += dt;
				frac = frac >= 1 ? 0.999999 : frac;
				toUpload[c + 3] = frac + whole;

			}
			
		}
		
		public function reset():void {
			
			for (var i:int = 0; i < total; i++) {
				var c:int = (i << 2);
				var w:Number = toUpload[c + 3];
		
				toUpload[c + 3] = int(w);

			}
		}
		
		public function launchNewProjectile(startPosition:Vector3D, endPosition:Vector3D, speed:Number=144):void {
			launchProjectileAtIndex(total, startPosition, endPosition, speed);
		}
		
		private var displace:Vector3D = new Vector3D();
		private var mySurface:Surface;
		
		private function launchProjectileAtIndex(index:int, startPosition:Vector3D, endPosition:Vector3D, speed:Number):void {

			var c:int = (index << 2);
			var vx:Number;
			var vy:Number;
			var vz:Number;
			
			displace.x = endPosition.x - startPosition.x;
			displace.y = endPosition.y - startPosition.y;
			displace.z = endPosition.z - startPosition.z;
      
           var totalTime:Number =  displace.length / speed;
            
            var scaler:Number = 1 / totalTime;
            displace.x *= scaler;
			displace.y *= scaler;
            displace.z *= scaler;
            displace.z += gravity * totalTime * 0.5;
  
			displace.w = Math.round(displace.x*startPosition.x + displace.y*startPosition.y + displace.z*startPosition.z);

			toUpload[c++] = displace.x;// startPosition.x;// displace.x; 
			toUpload[c++] = displace.y;
			toUpload[c++] = displace.z;// displace.z;
			toUpload[c] = displace.w;
		//	throw new Error(geometry.getAttributeValues(ATTRIBUTE));
			total++;
		//	getSurface(0).numTriangles = total * sampleNumTris;
		
		
		}
		
			override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
				
				_remainingTotal = total;
				
				
				
				
				if (_remainingTotal < batchAmount) {
					mySurface = _surfaces[0];
				
					_toUploadAmount = _remainingTotal;
				
				//	mySurface.numTriangles = _remainingTotal * sampleNumTris;
					mySurface.material.collectDraws(camera, mySurface, geometry, lights, lightsLength, useShadow, -1);
					
				}
				else {
					var count:int = 0;
				
					
				
					while (_remainingTotal > 0) {
						if (count >= _surfaces.length) {
							_surfaces[count] = _surfaces[0].clone();
							_surfacesLength = count;
						}
						mySurface = _surfaces[count];
						
						_toUploadAmount = _remainingTotal;
						if (_toUploadAmount > batchAmount) _toUploadAmount = batchAmount;
						
		
						mySurface.material.collectDraws(camera, mySurface, geometry, lights, lightsLength, useShadow, -1);
						
						_remainingTotal -= batchAmount;
						count++;
						
					}
				}
			}
			
			
			
			
		
		// -------------------
		
	
		
		///*
		private function calculateTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _transformProcedures[numMeshes];
			if (res != null) return res;
			res = _transformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSetTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "#c2=cUp",
			// dummy declarations (can remove once done..)
			//"mov t0, c1",
			//"mov t1, c2",
		//	"mov t1, a0",
		//	"mov t1, i0",
			// ----

				"mov t0, c[a0.x]",	// velocity and offset/time
				"mov t1, t0",
				"frc t0.w, t1.w",	// save fractional time into t0.w
				"sub t1.w, t1.w, t0.w",	// subtract away fractional to get whole number offset into t1.w
					
				"mul t1.xyz, t1.xyz, t1.www",	// origin launch position into t1 by multiplying velocity over offset
				"mul t0.w, t0.w, c1.w",  // now, save actual time t of t0.w from fractional by multiplying against MAX_TIME
	
				
				"mul t1.w, t0.x, t0.w, ",  // save out velocity.x*t offset
				"add t1.x, t1.x, t1.w",		// and add it to the launch position to get actual x arrow origin position
				"mul t1.w, t0.y, t0.w, ",  // save out velocity.y*t offset
				"add t1.y, t1.y, t1.w",  // and add it to the launch position to get actual y arrow origin position
			
				"mul t1.w, c1.x, t0.w", // save out  -.5*GRAVITY*t*t + velocity.z*t   gravitational offset over time
				"mul t1.w, t1.w, t0.w", 
				
				"add t1.z, t1.z, t1.w",  // and  LHS operand done, ADD it in!!
				
				"mul t1.w, t0.z, t0.w",
				"add t1.z, t1.z, t1.w",	// and RHS operand done, subtract it out to get actual z arrow origin position
				
				///*  // if considering orientation
				"mul t0.w, c1.z, t0.w",  // multiply gravitaitonal offset over time: GRAVITY*t  
				"sub t0.z, t0.z, t0.w",	// subtract this from the z alt component velocity to get final unnormalized velocity vector
			
				"nrm t0.xyz, t0.xyz",  // normalize the vector to get forward vector of arrow...along X direction! (2d east)
				"mov t3, t0", // no choice, t0 is used, t1 is to hold position,  t2 to hold axes! need to maintain reference to foward vector to allow crs later
				"mul t2.xyz, i0.xxx, t0.xyz",  // extend out position along x offset of vertex
				"add t1.xyz, t1.xyz, t2.xyz",
				"crs t0.xyz, t0.xyz, c2.xyz",  // cross product forward vector with up to get right...along Y direction (2d north)!
				"mul t2.xyz, i0.yyy, t0.xyz",  // extend out position along y offset of vertex
				"add t1.xyz, t1.xyz, t2.xyz",
				"crs t0.xyz, t0.xyz, t3.xyz",  // cross product right vector with forward vector to get actual UP...along Z direction
				"mul t2.xyz, i0.zzz, t0.xyz",  // extend out position along z offset of vertex
				"add t1.xyz, t1.xyz, t2.xyz",
				"mov t1.w, c1.z",	// w property of 1 needed?
				// */
				
		
			// if not considering orientation	
			//"add t1.xyz, t1.xyz, i0.xyz",
			
			
				"mov t1.w, i0.w",
				"mov o0, t1"]);
				
			res.assignConstantsArray(numMeshes * constantsPerMesh);
			
			return res;
		}
		//*/

		/*
		private function calculateDeltaTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _deltaTransformProcedures[numMeshes];
			if (res != null) return res;
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSetDeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		*/
		
		public function get maxProjectileTravelTime():Number 
		{
			return _maxProjectileTravelTime;
		}
		
		public function set maxProjectileTravelTime(value:Number):void 
		{
			_maxProjectileTravelTime = value;
			_maxProjectileTravelTimeMult = 1/value;
		}
		
	}

}