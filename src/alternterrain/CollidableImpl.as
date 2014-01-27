package alternterrain 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
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
		
		private var terrainFirstTime:Boolean = true;
		
		private var waterPlane:CollidableMesh;
		
		public function CollidableImpl(terrain:TerrainLOD, waterPlane:Mesh) 
		{
			
			this.terrain = terrain;
			waterPlane = waterPlane.clone() as Mesh;
			waterPlane.z  -=31;
			
			this.waterPlane = new CollidableMesh(waterPlane);
			
			terrainTransform = new Transform3D();
			terrainTransformInverse = new Transform3D();
			terrainCollideTransform = new Transform3D();
			terrainGeom = new Geometry();
			
		}
		
		
	
		/* INTERFACE systems.collisions.IECollidable */
		
		
		
		public function collectGeometry(collider:EllipsoidCollider):void 
		{
			// We assume collider inverse matrix and sphere is prepare() alraedy when this is called!
				waterPlane.collectGeometry(collider);
				
				if ( prepareObject(collider, terrain, terrainTransform, terrainTransformInverse, terrainCollideTransform, terrainGeom) ) {
				
					terrain.setupCollisionGeometry(collider.sphere, terrainGeom.vertices, terrainGeom.indices, 0, 0 );
						
						
					terrainGeom.numVertices = terrain.numCollisionTriangles * 3;
					terrainGeom.numIndices = terrain.numCollisionTriangles * 3;
			
				}
				
		}
		
		public var alwaysIntersect:Boolean = false;
		
		private function prepareObject(collider:EllipsoidCollider, object:Object3D, objTransform:Transform3D, objTransformInverse:Transform3D, collisionTransform:Transform3D, geom:Geometry):Boolean {
			if (object.transformChanged || terrainFirstTime) {
				objTransform.compose(object._x, object._y, object._z, object._rotationX, object._rotationY, object._rotationZ, object._scaleX, object._scaleY, object._scaleZ);
				objTransformInverse.calculateInversion(objTransform);
				terrainFirstTime = false;
			}
			
			// Check collision with the bound
			var intersects:Boolean = true;
			
			if (object.boundBox != null) {
				collisionTransform.combine(objTransformInverse, collider.matrix);
				collider.calculateSphere(collisionTransform);
				intersects = alwaysIntersect || object.boundBox.checkSphere(collider.sphere);  
			}
			alwaysIntersect = false;
			
			if (intersects) {
				collisionTransform.combine(collider.inverseMatrix, objTransform); 
				collider.addGeometry(geom, collisionTransform);
			}
			return intersects;
		}
		
		
	}

}