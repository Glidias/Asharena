package alternativa.a3d.objects 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSet;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.alternativa3d;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	use namespace alternativa3d;
	/**
	 * A UV MeshSet supporting up to 60 independantly oriented arc meshes to be drawn in 1 draw call
	 * @author Glenn Ko
	 */
	public class UVMeshSet2 extends Mesh
	{
		private var batchAmount:int;
	
		private var sampleNumTris:int;
		private static var BATCH_AMOUNT:int = 60;
		
		private static var _transformProcedures:Dictionary = new Dictionary();
		private static var _deltaTransformProcedures:Dictionary = new Dictionary();
		
		public var toUpload:Vector.<Number> = new Vector.<Number>();
		private var toUploadData:Vector.<Number>;
		private var tempUploadData:Vector.<Number>;
		public var total:int = 0;
		private static const ATTRIBUTE:int = GeometryUtil.ATTRIBUTE;
		private var constantsPerMesh:int;
		
		public var distanceCap:Number = 150;
		public var addStartZ:Number = 32;
		public var rayGeometry:Geometry;
		public var defaultZOffset:Number=77;

		
		public function cleanup(amountToKeep:int = 0):void {
			
			total = amountToKeep;
			
			var len:int = amountToKeep * 4 * constantsPerMesh;
			toUpload.length = len;
			

			
			if (tempUploadData != null) {
				if (amountToKeep >= batchAmount) {
					amountToKeep = batchAmount;
				}
				len = amountToKeep * 4 * constantsPerMesh;
				tempUploadData.length = len;
			}
		}
		
		public function UVMeshSet2(arcGeometry:Geometry, rayGeometry:Geometry, material:Material, reuseGeometry:Geometry=null, reuseRayGeometry:Geometry=null ) 
		{
			super();
			
			batchAmount = BATCH_AMOUNT;
			sampleNumTris = arcGeometry.numTriangles;
			constantsPerMesh = 2;
			geometry = reuseGeometry!=null ? reuseGeometry :  GeometryUtil.createDuplicateGeometry(arcGeometry, batchAmount, constantsPerMesh);
			this.rayGeometry = rayGeometry;
			
			addChild( new UVMeshSet2a(batchAmount, toUpload, rayGeometry, material, reuseRayGeometry) );
			
			mySurface = addSurface( material, 0, sampleNumTris*total  );
			
			transformProcedure = calculateTransformProcedure(batchAmount);
	
		
	
			boundBox = null;
		}
		
		public static function createDoubleSidedPlane(mat:Material, segments:int=24,breath:Number=4):Geometry {
			var plane1:Plane = new Plane(1,breath,segments,1,false,false,mat,mat);
			var plane2:Plane =new Plane(1,breath,segments,1,false,true,mat,mat);
			var root:Object3D = new Object3D();
			root.addChild(plane1);
			root.addChild(plane2);
			var combine:MeshSet = new MeshSet(root);
			alignGeometry(combine.geometry);
			return combine.geometry;
		}
		
		public static function alignGeometry(geom:Geometry):void {
			var ve:Vector.<Number> = geom.getAttributeValues(VertexAttributes.POSITION);
			var len:int = ve.length;
			for (var i:int = 0; i < len; i += 3) {
				ve[i] += .5;
			}
			geom.setAttributeValues(VertexAttributes.POSITION, ve);
		}
		
		
		public function launchNewProjectile(startPosition:Vector3D, endPosition:Vector3D):void {
			//launchProjectileAtIndex(total, startPosition, endPosition);
			var base:int = total * 8;
			toUpload[base++] = startPosition.x;
			toUpload[base++] =startPosition.y;
			toUpload[base++] = startPosition.z;
			toUpload[base++ ] = 1;
				
			toUpload[base++] = endPosition.x;
			toUpload[base++] =endPosition.y;
			toUpload[base++] =endPosition.z;
			toUpload[base++ ] = defaultZOffset;
			
			total++;
			
		}
		

		private var _remainingTotal:int;
		private var _toUploadAmount:int;
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
			
			var attrib:int = VertexAttributes.TEXCOORDS[0];
			drawUnit.setVertexBufferAt(vertexShader.findVariable("aUV"), geometry.getVertexBuffer(attrib), geometry._attributesOffsets[attrib], Context3DVertexBufferFormat.FLOAT_2);
	
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), -.5, 2, .5, distanceCap);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cUp"), 0, 0, 1, 0);
			
			//drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
			
	
			drawUnit.setVertexConstantsFromVector( 0, toUploadData, _toUploadAmount*constantsPerMesh );
	
			//throw new Error(e.message + ":"+_toUploadAmount + ", " + toUploadData.length);
	
	
			
			//if (triCount != surface.numTriangles) {
				surface.numTriangles = _toUploadAmount * sampleNumTris;
			//}
					
		}
		
		

		private var mySurface:Surface;
		
		
			override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
				
				_remainingTotal = total;
				
				
				if (_remainingTotal < batchAmount) {
					mySurface = _surfaces[0];
					toUploadData = toUpload;
					_toUploadAmount = _remainingTotal;
				
				//	mySurface.numTriangles = _remainingTotal * sampleNumTris;
					mySurface.material.collectDraws(camera, mySurface, geometry, lights, lightsLength, useShadow, -1);
					
				}
				else {
					var count:int = 0;
					if (tempUploadData == null) tempUploadData = new Vector.<Number>(batchAmount*constantsPerMesh*4, true);
					
					toUploadData = tempUploadData;
					while (_remainingTotal > 0) {
						if (count >= _surfaces.length) {
							_surfaces[count] = _surfaces[0].clone();
							_surfacesLength = count;
						}
						mySurface = _surfaces[count];
						
						fillTempUploadData( total - _remainingTotal, _remainingTotal);
						//mySurface.numTriangles = _remainingTotal*sampleNumTris;
						mySurface.material.collectDraws(camera, mySurface, geometry, lights, lightsLength, useShadow, -1);
						
						_remainingTotal -= batchAmount;
						count++;
						
					}
				}
			}
			
			private function fillTempUploadData(startIndex:int, len:int):void 
			{
				if (len > batchAmount) len = batchAmount;
				_toUploadAmount = len;
				
				len *= constantsPerMesh;
				len *= 4;

				startIndex *= 4;
				startIndex *= constantsPerMesh;
				for (var i:int = 0; i < len; i++) {
					tempUploadData[i] = toUpload[startIndex + i];
				}
			}
			
			
		
		// -------------------
		
	
		
		///*
		private function calculateTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _transformProcedures[numMeshes];
			if (res != null) return res;
			res = _transformProcedures[numMeshes] = new Procedure(null, "UVMeshSet2TransformProcedure");
			res.compileFromArray(["#a0=joint", "#a1=aUV", "#c1=cVars", "#c2=cUp",
			// dummy declarations (can remove once done..)
			//"mov t0, c1",
			//"mov t1, c2",
			//"mov t1, a0",
		//	"mov t1, a1",
		//	"mov t1, i0",
			// ----

				"mov t1, c[a0.x]",	// initial position t1
				"add t0.x, c2.z, a0.x",
				"mov t0, c[t0.x]",  // end position t0
				
				
				// Find actual start position from initial position t1 and re-save into t1
				"sub t2.xyz, t1.xyz, t0.xyz",
				"mov t2.z, c2.x", // Normalize 2D vector
				"nrm t3.xyz, t2.xyz",
				
				//"dp2 t1.w, t2.xy, t1.xy",  // full distance check, dotProduct of normal unit vector t3 over t2 displacement vector.
				"mul t1.w, t3.x, t2.x",
				"mul t2.w, t3.y, t2.y",
				"add t1.w, t1.w, t2.w",
				"mul t1.w, t1.w, c1.z",
				"min t1.w, t1.w, c1.w",		// cap full distance to get minimum distance cap
				
				"div t3.w, t1.w, c1.w",
				"sat t3.w, t3.w",
				"mul t0.w, t3.w, t0.w",
				
				
				//"mov t1.w, c1.w",
				
				// determine startPosition from initialPosition
				"mul t1.xy t3.xy, t1.ww",    // get scalar vector of t2 normal unit multiplied over scalar
				"add t1.xy, t1.xy, t0.xy",
				
				"mov t1.z, c[a0.x].z",  // set z component and ascend
				"add t1.z, t1.z, t0.w",
			
				
				
				
				
				"sub t2.xyz, t1.xyz, c[a0.x].xyz",
				"mov t2.z, c2.x",  // Normalize 2D vector
				"nrm t3.xyz, t2.xyz",  // need to scale velocity unit vector of launcher so that x/y matches endPt.xy
				
				"sub t2.xyz, t0.xyz, t1.xyz",
				"div t2.x, t2.x, t3.x",
				"div t2.y, t2.y, t3.y",
				"add t2.w, t2.x, t2.y",  // scalar determined with sum of x and y components along 2d distance
				
				
				"mul t2.xyz, t3.xyz, t2.www",  // launch velocity determined
				// determine gravity with launch velocity
				"sub t3.z, t0.z, t1.z",
				"sub t3.z, t3.z, t2.z",
				"mul t3.z, t3.z, c1.y",  // GRAVITY: t3.w =  2(ey-sy-launchvelocity);
				"mul t3.x, t3.z, c1.z", // GRAVITY*.5: t3.x

			
				"mov t0.w, a1.x",  // TODO: time t at t0.w, and velocity xyz at t0
				"sub t0.xyz, t0.xyz, t1.xyz",
				"sub t0.z, t0.z, t3.x",
				
				"mul t1.w, t0.x, t0.w, ",  // save out velocity.x*t offset
				"add t1.x, t1.x, t1.w",		// and add it to the launch position to get actual x arrow origin position
				"mul t1.w, t0.y, t0.w, ",  // save out velocity.y*t offset
				"add t1.y, t1.y, t1.w",  // and add it to the launch position to get actual y arrow origin position
			
				"mul t1.w, t3.x, t0.w", // save out  -.5*GRAVITY*t*t + velocity.z*t   gravitational offset over time
				"mul t1.w, t1.w, t0.w", 
				
				"add t1.z, t1.z, t1.w",  // and  LHS operand done, ADD it in!!
				
				"mul t1.w, t0.z, t0.w",
				"add t1.z, t1.z, t1.w",	// and RHS operand done, subtract it out to get actual z arrow origin position
				
				///*  // if considering orientation
				"mul t0.w, t3.z, t0.w",  // multiply gravitaitonal offset over time: GRAVITY*t  
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
				"mov t1.w, t3.z",	// w property of 1 needed?
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
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "UVMeshSet2DeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		*/
		
	
		
	}

}