package alternativa.engine3d.objects 
{
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpriteMeshSetClonesContainer extends MeshSetClonesContainer
	{
		private static var MESH:Mesh;
		
		public function SpriteMeshSetClonesContainer(material:Material, meshesPerSurface:uint = 0, cloneClass:Class = null, flags:int = 1) 
		{
			if (MESH == null) {
				MESH = createMeshGeometry();
			}
			super(MESH, material, meshesPerSurface, cloneClass, figure);
		}
		
		private function createMeshGeometry():Mesh 
		{
			var mesh:Mesh = new Mesh();
			mesh.geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(1, 0, 1, 1, 0, 0, 4);
			return mesh;
		}
		
	}

}