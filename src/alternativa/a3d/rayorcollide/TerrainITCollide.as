package alternativa.a3d.rayorcollide 
{
	import altern.ray.IRaycastImpl;
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternterrain.objects.TerrainLOD;
	import components.Transform3D;
	import flash.geom.Vector3D;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.ITCollidable;
	import alternativa.engine3d.alternativa3d;
	import util.geom.Geometry;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TerrainITCollide implements ITCollidable, IRaycastImpl
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
			terrainGeom.numVertices =terrainGeom.numIndices= terrain.numCollisionTriangles * 3;
			collider.addGeometry(terrainGeom, baseTransform);
			
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
		
		
		/* INTERFACE altern.ray.IRaycastImpl */
		
		public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
		{
			// lazy shortcut atm. Consider using IRaycastImpl be handled by QuadTreePage itself
			var pt:RayIntersectionData = terrain.intersectRay(origin, direction);
			var minTime:Number = output.w != 0 ? output.w : direction.w != 0 ? direction.w : 1e22;
			if (pt != null && pt.time < minTime) {
				output.x = pt.point.x;
				output.y = pt.point.y;
				output.z = pt.point.z;
				output.w = pt.time;
				return output;
			}
			return null;
		}
		
	}

}