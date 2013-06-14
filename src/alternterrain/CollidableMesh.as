package alternterrain 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	import components.Transform3D;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.IECollidable;
	import util.geom.Geometry;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CollidableMesh implements IECollidable
	{
		
		private var geometry:Geometry;
		
		private var transform:Transform3D;
		private var transformInverse:Transform3D;
		private var collideTransform:Transform3D;
		
		private var firstTime:Boolean = true;
		private var mesh:Mesh;
		
		public function CollidableMesh(mesh:Mesh) 
		{
			this.mesh = mesh;
			geometry = new Geometry();
			geometry.setVertices(mesh.geometry.getAttributeValues(VertexAttributes.POSITION));
			geometry.setIndices(mesh.geometry._indices);
			
			transform = new Transform3D();
			transformInverse = new Transform3D();
			collideTransform = new Transform3D();
		}
		
		/* INTERFACE systems.collisions.IECollidable */
		
		public function collectGeometry(collider:EllipsoidCollider):void 
		{
			prepareObject(collider, mesh, transform, transformInverse, collideTransform, geometry);
		}
		
		private function prepareObject(collider:EllipsoidCollider, object:Object3D, objTransform:Transform3D, objTransformInverse:Transform3D, collisionTransform:Transform3D, geom:Geometry):Boolean {
			if (object.transformChanged || firstTime) {
				
				objTransform.compose(object._x, object._y, object._z, object._rotationX, object._rotationY, object._rotationZ, object._scaleX, object._scaleY, object._scaleZ);
				
				objTransformInverse.calculateInversion(objTransform);
				firstTime = false;
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
				collider.addGeometry(geom, collisionTransform);
			}
			return intersects;
		}
		
	}

}