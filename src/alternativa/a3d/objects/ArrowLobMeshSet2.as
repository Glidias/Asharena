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
	public class ArrowLobMeshSet2 extends Mesh
	{
		private var batchAmount:int;
		

		private var sampleNumTris:int;
		private static var BATCH_AMOUNT:int = 60;
		
		private static var _transformProcedures:Dictionary = new Dictionary();
		private static var _deltaTransformProcedures:Dictionary = new Dictionary();
		
		public var toUpload:Vector.<Number> = new Vector.<Number>();
		public var total:int = 0;
		private static const ATTRIBUTE:int = GeometryUtil.ATTRIBUTE;
		private var constantsPerMesh:int;
		
		public var maxTimeInterval:Number = 4;
		public var gravity:Number = 266;
		public var idleArrowLifetime:Number = 4;
		
		public function adjustArrowLifeSettings(idleTimeBeforeCleanup:Number = 4, registryFlushTime:Number = 4 ):void {
			idleArrowLifetime = idleTimeBeforeCleanup;
			maxTimeInterval = 4;
		}
		
		public function setPermanentArrows():void {
			idleArrowLifetime = Number.MAX_VALUE;
		
			maxTimeInterval = Number.MAX_VALUE;
		}
		
	//	private var freeSlots:Vector.<int> = new Vector.<int>();
		
		
		public function setGravity(val:Number):void {
			gravity = val;
		}
		
		
		
		public function ArrowLobMeshSet2(arrowGeometry:Geometry, material:Material) 
		{
			super();

			batchAmount = BATCH_AMOUNT;
			sampleNumTris = arrowGeometry.numTriangles;
			constantsPerMesh = 2;
			geometry = GeometryUtil.createDuplicateGeometry(arrowGeometry, batchAmount, constantsPerMesh);
			
			mySurface = addSurface( material, 0, sampleNumTris*total  );
			
			transformProcedure = calculateTransformProcedure(batchAmount);
	
			//	deltaTransformProcedure = calculateDeltaTransformProcedure(batchAmount);
		//	setPermanentArrows();
			
			
			
			
			boundBox = null;
		}
		

		private var _remainingTotal:int;
		private var _toUploadAmount:int;
		
		private var timeStamp:Number = 0;
		
		
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
	
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), -.5 * gravity, idleArrowLifetime, gravity, timeStamp);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cUp"), 0, 0, 1, 0);
			
			//drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
			
	
			setVertexConstantsFromVector(drawUnit, 0, toUpload, _toUploadAmount*constantsPerMesh, particleDrawCount  );
	
			//throw new Error(e.message + ":"+_toUploadAmount + ", " + toUploadData.length);
	
	
			
			//if (triCount != surface.numTriangles) {
				surface.numTriangles = _toUploadAmount * sampleNumTris;
			//}
				particleDrawCount += _toUploadAmount;
		}
		
		
		
		public function update(time:Number):void {
			
			timeStamp += time;
			if (timeStamp >= maxTimeInterval) {
				cleanup();
			}
			
		}
		
		private function cleanup():void 
		{
			var capCheck:int = total - 1;
			for (var i:int = 0; i < total; i++) {
				var base:int = i * 8;
				
				var timeOfLaunch:Number = toUpload[base + 3];
				var t:Number = timeStamp - timeOfLaunch;
				
				if ( t - toUpload[base+7]  < idleArrowLifetime ) {  // still within visible state
					toUpload[base+3] = timeOfLaunch - timeStamp;
				}
				else {  // remove
					if (i != capCheck ) { // do pop back
						var count:int = capCheck * 8;
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						toUpload[base++] = toUpload[count++];
						i--;
					}
				
					total--;
					capCheck--;  
				}
			}
			
			timeStamp = 0;
		}
		
		
		
		public function reset():void {
			
			timeStamp = 0;
			toUpload.length = 0;
			total = 0;
			
		}
		
		public function launchNewProjectile(startPosition:Vector3D, endPosition:Vector3D, speed:Number=1044 ):void {
			//launchProjectileAtIndex(total, startPosition, endPosition);
				displace.x = endPosition.x - startPosition.x;
			displace.y = endPosition.y - startPosition.y;
			displace.z = endPosition.z - startPosition.z;
      
           var totalTime:Number =  displace.length / speed;
		 
			
			var base:int = total * 8;
			toUpload[base++] = startPosition.x;
			toUpload[base++] =startPosition.y;
			toUpload[base++] = startPosition.z;
			toUpload[base++ ] = timeStamp;
				
			toUpload[base++] = endPosition.x;
			toUpload[base++] =endPosition.y;
			toUpload[base++] =endPosition.z;
			toUpload[base++ ] = totalTime;
			
			total++;
			
		}
		
		public function launchNewProjectileWithTimeSpan(startPosition:Vector3D, endPosition:Vector3D, time:Number=1 ):void {
			//launchProjectileAtIndex(total, startPosition, endPosition);
		
		   
			
			var base:int = total * 8;
			toUpload[base++] = startPosition.x;
			toUpload[base++] =startPosition.y;
			toUpload[base++] = startPosition.z;
			toUpload[base++ ] = timeStamp;
				
			toUpload[base++] = endPosition.x;
			toUpload[base++] =endPosition.y;
			toUpload[base++] =endPosition.z;
			toUpload[base++ ] = time;
			
			total++;
			
		}
		
		private var displace:Vector3D = new Vector3D();
		private var mySurface:Surface;
		
	
		
			override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
				
				_remainingTotal = total;
				
				
				
				particleDrawCount = 0;
				
				if (_remainingTotal < batchAmount) {
					mySurface = _surfaces[0];
				
					_toUploadAmount = _remainingTotal;
				
				//	mySurface.numTriangles = _remainingTotal * sampleNumTris;
					mySurface.material.collectDraws(camera, mySurface, geometry, lights, lightsLength, useShadow, -1);
					
				}
				else {
					var count:int = 0;
					//if (tempUploadData == null) tempUploadData = new Vector.<Number>(batchAmount*constantsPerMesh*4, true);
				
					//toUploadData = tempUploadData;
					while (_remainingTotal > 0) {
						if (count >= _surfaces.length) {
							_surfaces[count] = _surfaces[0].clone();
							_surfacesLength = count;
						}
						mySurface = _surfaces[count];
						
						//fillTempUploadData( total - _remainingTotal, _remainingTotal);
						//mySurface.numTriangles = _remainingTotal*sampleNumTris;
						
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
			res = _transformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSet2TransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "#c2=cUp",
			// dummy declarations (can remove once done..)
			//"mov t0, c1",
			//"mov t1, c2",
		//	"mov t1, a0",
		//	"mov t1, i0",
			// ----

				"mov t1, c[a0.x]",	// start position t1
				"add t0.x, c2.z, a0.x",
				"mov t0, c[t0.x]",  // end position t0
				
				"mov t2.w, t0.w", // we need this later, t2.w will be the totalTime of arrow travel
				
				
				// get velocity t0.xyz
				"sub t0.xyz, t0.xyz, t1.xyz",
				"div t0.xyz, t0.xyz, t0.www",
				"mul t0.w, c1.x, t0.w",  
				"sub t0.z, t0.z, t0.w",
				
				// get time t0.w
				"sub t0.w, c1.w, t1.w",  // now, save actual time by subtracting timeStamp - launchTime. 
				"sub t4.w, t0.w, t2.w",  // t - totalTime  // t4 is reserved for visMultiplier
				"slt t4.w, t4.w, c1.y",  //visMmultiplier  1/0
				
				"min t0.w, t0.w, t2.w",  // cap time for rendering of arrow (so arrows stick to the ground..)
				//t = min( t, totalTime)
				//"mov t0.w, c2.x",
				
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


				"mul t1.xyz, t1.xyz, t4.www",	
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
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSet2DeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		*/
		
		
		
	}

}