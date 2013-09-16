package alternativa.a3d.cullers 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.objects.IMeshSetCloneCuller;
	import alternativa.engine3d.objects.MeshSetClone;
	import de.polygonal.motor.geom.primitive.AABB2;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Box2DAABBCuller extends AABB2 implements IMeshSetCloneCuller
	{

		public function Box2DAABBCuller() 
		{
			
		}
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetCloneCuller */
		
		public function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>):int 
		{
			var count:int = 0;
			for (var i:int = 0; i < numClones; i++ ) {
				var candidate:MeshSetClone = clones[i];
				var cb:BoundBox = candidate.root.boundBox;
				if (cb== null) {
					collector[count++] = candidate;
					continue;
				}
				if (candidate.root.x  + cb.maxX < minX || candidate.root.x + cb.minX > maxX || candidate.root.y + cb.maxY < minY ||  candidate.root.y + cb.minY > maxY) continue;
				collector[count++] = candidate;
			}
			return count;
		}
		
	}

}