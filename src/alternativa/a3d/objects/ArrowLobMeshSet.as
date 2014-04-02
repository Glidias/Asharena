package alternativa.a3d.objects 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.alternativa3d;
	import flash.display3D.Context3DVertexBufferFormat;
	use namespace alternativa3d;
	/**
	 * Yes,  ~120 arrows/projectiles per draw call! Let thy arrows blot the sun!!
	 * We determine arrow position and orientation, from velocity, offset and time...within GPU itself.
	 * @author Glenn Ko
	 */
	public class ArrowLobMeshSet extends Mesh
	{
		private var batchAmount:int;
		private var _maxProjectileTravelTime:Number;
		private var _maxProjectileTravelTimeMult:Number;
		private var sampleNumTris:int;
		private static var BATCH_AMOUNT:int = 120;
		
		public var toUpload:Vector.<Number> = new Vector.<Number>();
		public var total:int = 0;
		
		public function ArrowLobMeshSet(arrowGeometry:Geometry, maxProjectileTravelTime:Number=10) 
		{
			super();
			this.maxProjectileTravelTime = maxProjectileTravelTime;
			batchAmount = BATCH_AMOUNT;
			sampleNumTris = arrowGeometry.numTriangles;
			geometry = GeometryUtil.createDuplicateGeometry(arrowGeometry, batchAmount, 1);
			
			transformProcedure = calculateTransformProcedure(batchAmount);
			deltaTransformProcedure = calculateDeltaTransformProcedure(batchAmount);
			
			this.maxProjectileTravelTime = maxProjectileTravelTime;
		}
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
	
			
			
			var triCount:int =  total * sampleNumTris;
			if (triCount != surface.numTriangles) {
				surface.numTriangles = triCount;
			}
					
		}
		
		private function calculateTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _transformProcedures[numMeshes];
			if (res != null) return res;
			res = _transformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSetTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m34 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			res.assignConstantsArray(numMeshes*constantsPerMesh);
			return res;
		}

		private function calculateDeltaTransformProcedure(numMeshes:int):Procedure {
			var res:Procedure = _deltaTransformProcedures[numMeshes];
			if (res != null) return res;
			res = _deltaTransformProcedures[numMeshes] = new Procedure(null, "ArrowLobMeshSetDeltaTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", "sub t0, a0.x, c1.x", "m33 o0.xyz, i0, c[t0.x]", "mov o0.w, i0.w"]);
			return res;
		}
		
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