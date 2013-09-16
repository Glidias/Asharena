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
	public class Box2DPointCuller extends AABB2 implements IMeshSetCloneCuller
	{

		public function Box2DPointCuller() 
		{
			
		}
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetCloneCuller */
		
		public function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>):int 
		{
			var count:int = 0;
			for (var i:int = 0; i < numClones; i++ ) {
				var candidate:MeshSetClone = clones[i];
				if (candidate.root.x < minX || candidate.root.x > maxX || candidate.root.y < minY ||  candidate.root.y > maxY) continue;
				collector[count++] = candidate;
			}
			return count;
		}
		
	}

}