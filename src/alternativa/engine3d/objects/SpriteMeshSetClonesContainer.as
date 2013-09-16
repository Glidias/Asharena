package alternativa.engine3d.objects 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpriteMeshSetClonesContainer extends MeshSetClonesContainer
	{
		private static var MESH:Mesh;
		public var uvData:Vector.<Number> = new Vector.<Number>();
		
		/**
		 * 
		 * @param	material  A TextureAtlasMaterial or variety thereof
		 * @param	meshesPerSurface	
		 */
		public function SpriteMeshSetClonesContainer(material:Material, meshesPerSurface:uint = 0) 
		{
			_material = material;
			if (MESH == null) {
				MESH = createMeshGeometry();	
			}
			constantsPerMesh = 4;
			if (meshesPerSurface == 0) meshesPerSurface = 30;
			super(MESH, material, meshesPerSurface, SpriteMeshSetClone, 0);
		}
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			super.setTransformConstants(drawUnit, surface, vertexShader, camera);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("spriteSet"), 0, 0, 0, 3);
			
					
		}
		override protected function setupMesh(drawUnit:DrawUnit, cloneIndex:int, firstRegister:int, mesh:Mesh):void {
			drawUnit.setVertexConstantsFromTransform(firstRegister, mesh.localToGlobalTransform);
			var sprMeshSetClone:SpriteMeshSetClone  = visibleClones[cloneIndex] as SpriteMeshSetClone;
			drawUnit.setVertexConstantsFromNumbers(firstRegister + 3, 
			sprMeshSetClone.u
			,sprMeshSetClone.v
			,sprMeshSetClone.uw
			,sprMeshSetClone.vw);
	
		}
		
		
		private function createMeshGeometry():Mesh 
		{
			var mesh:Plane = new Plane(1, 1, 1, 1, false, false, _material, _material);
			
		//	mesh.geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(1, 0, 1, 1, 0, 0, 4);
		//	mesh.addSurface(_material, 0, 2);
			return mesh;
		}
		
	}

}