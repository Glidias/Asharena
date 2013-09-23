package alternativa.a3d.cullers 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.objects.IMeshSetCloneCuller;
	import alternativa.engine3d.objects.MeshSetClone;
	import de.polygonal.motor.geom.primitive.AABB2;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Box2DPointCuller extends AABB2 implements IMeshSetCloneCuller
	{
		private var offsetObj:Object3D;

		public function Box2DPointCuller(offsetObj:Object3D) 
		{
			this.offsetObj = offsetObj;
			
		}
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetCloneCuller */
		
		public function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>, camera:Camera3D, object:Object3D):int 
		{
			var count:int = 0;
			for (var i:int = 0; i < numClones; i++ ) {
				var candidate:MeshSetClone = clones[i];
				
				var x:Number;
				var y:Number;
				var root:Object3D = candidate.root;
				if (root._parent != null) {
					var t:Transform3D = root._parent.transform;
					x = t.a * root._x + t.b * root._y  + t.d;
					y = t.e * root._x + t.f * root._y  + t.h;
					x += offsetObj._x;
					y += offsetObj._y;
				}
				else {
					x = offsetObj._x + root._x;
					y = offsetObj._y + root._y;;
				}
				
				
				if (x < minX || x > maxX || y < minY ||  y > maxY) continue;
				collector[count++] = candidate;
			}
			return count;
		}
		
	}

}