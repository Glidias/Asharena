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
	public class LineSegmentSet extends Mesh
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
		
		private var preventZFighting:Boolean;
		public var zBufferPrecision:int = 16;
		
	
		
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
		
		public function LineSegmentSet(material:Material, segmentGeometry:Geometry, reuseGeometry:Geometry=null, preventZFighting:Boolean=false ) 
		{
			super();
			
			this.preventZFighting = preventZFighting;
			batchAmount = BATCH_AMOUNT;
			sampleNumTris = segmentGeometry.numTriangles;
			constantsPerMesh = 1;
			geometry = reuseGeometry!=null ? reuseGeometry :  GeometryUtil.createDuplicateGeometry(segmentGeometry, batchAmount, constantsPerMesh);
			
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
		
		
		
		

		private var _remainingTotal:int;
		private var _toUploadAmount:int;
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
			

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
						/*
						if (count >= _surfaces.length) {
							_surfaces[count] = _surfaces[0].clone();
							_surfacesLength = count;
						}
						mySurface = _surfaces[count];
						*/
						mySurface = _surfaces[0];
						
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
			res = _transformProcedures[numMeshes] = new Procedure(null, "LineSegmentSetTransformProcedure");
			res.compileFromArray(["#a0=joint", "#a1=aUV", "#c1=cVars", "#c2=cUp",
			
			
			// dummy declarations (can remove once done..)
			//"mov t0, c1",
			//"mov t1, c2",
			//"mov t1, a0",
		//	"mov t1, a1",
		//	"mov t1, i0",
			// ----

				"mov t1, c[a0.x]",	// start position t1
				"add t0.x, c1.w, a0.x",
				"mov t0, c[t0.x]",  // end position t0
			
				"mov t0.w, a1.x",  
				"sub t0.xyz, t0.xyz, t1.xyz",
				"sub t0.z, t0.z, c1.x",
				
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
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "LineSegmentSetDeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		*/
		
	
		
	}

}