package alternterrain 
{
	import alternativa.engine3d.core.Object3D;
	import alternterrain.objects.TerrainLOD;
	import components.Transform3D;
	import flash.geom.Vector3D;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.IECollidable;
	import util.geom.Geometry;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * This implementation of collisions involves a flattened 1-level approach (root -> children) with terrain.
	 * 
	 * @author Glenn Ko
	 */
	public class CollidableImpl implements IECollidable
	{
		private var terrain:TerrainLOD;
		private var terrainGeom:Geometry;
		
		private var terrainTransform:Transform3D;
		private var terrainTransformInverse:Transform3D;
		private var terrainCollideTransform:Transform3D;
		
		public function CollidableImpl(terrain:TerrainLOD) 
		{
			
			this.terrain = terrain;
			terrainTransform = new Transform3D();
			terrainTransformInverse = new Transform3D();
			terrainCollideTransform = new Transform3D();
			terrainGeom = new Geometry();
			
		}
		
	
		/* INTERFACE systems.collisions.IECollidable */
		
		public function collectGeometry(collider:EllipsoidCollider):void 
		{
			// We assume collider inverse matrix and sphere is prepare() alraedy when this is called!
			
			if ( prepareObject(collider, terrain, terrainTransform, terrainTransformInverse, terrainCollideTransform, terrainGeom) ) {
				terrain.setupCollisionGeometry(collider.sphere, terrainGeom.vertices, terrainGeom.indices, 0, 0 );
				terrainGeom.numVertices = terrain.numCollisionTriangles * 3;
				terrainGeom.indices.length = terrain.numCollisionTriangles * 3;
			}
			
		}
		
		private function prepareObject(collider:EllipsoidCollider, object:Object3D, objTransform:Transform3D, objTransformInverse:Transform3D, collisionTransform:Transform3D, geom:Geometry):Boolean {
			if (object.transformChanged) {
				objTransform.compose(object._x, object._y, object._z, object._rotationX, object._rotationY, object._rotationZ, object._scaleX, object._scaleY, object._scaleZ);
				objTransformInverse.calculateInversion(terrainTransform);
			}
			
			
			// Check collision with the bound
			var intersects:Boolean = true;
			
			if (object.boundBox != null) {
				collisionTransform.combine(objTransformInverse, collider.matrix);
				collider.calculateSphere(collisionTransform);
				intersects = object.boundBox.checkSphere(collider.sphere);  
			}
			if (intersects) {
				collisionTransform.combine(collider.inverseMatrix, objTransform); 
				collider.geometries.push(geom);
				//collider.transforms.push   // TODO: push implementable collision transforms per object!
			}
			return intersects;
		}
		
		
	}

}