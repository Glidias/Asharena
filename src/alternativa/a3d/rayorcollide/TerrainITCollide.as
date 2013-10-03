package alternativa.a3d.rayorcollide 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternterrain.objects.TerrainLOD;
	import components.Transform3D;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.ITCollidable;
	import alternativa.engine3d.alternativa3d;
	import util.geom.Geometry;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TerrainITCollide implements ITCollidable
	{
		public var terrain:TerrainLOD;
		private var terrainGeom:Geometry;
		
		public function TerrainITCollide(terrain:TerrainLOD) 
		{
			this.terrain = terrain;
			terrainGeom = new Geometry();
		}
		
		/* INTERFACE systems.collisions.ITCollidable */
		
		public function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):void 
		{
			terrain.setupCollisionGeometry(collider.sphere, terrainGeom.vertices, terrainGeom.indices, 0, 0 );	
			terrainGeom.numVertices = terrain.numCollisionTriangles * 3;
			terrainGeom.numIndices = terrain.numCollisionTriangles * 3;
		}
		
		/**
		 * Shortcut method to create a collision bound node for a (already-constructed) TerrainLOD instance
		 * @param	terrain
		 * @return
		 */
		public static function createNode(terrain:TerrainLOD):CollisionBoundNode {
			var node:CollisionBoundNode = new CollisionBoundNode();
			node.setup(terrain,  new TerrainITCollide(terrain));
			return node;
			
		}
		
	}

}