package alternativa.a3d.cullers 
{
	import alternativa.engine3d.objects.IMeshSetCloneCuller;
	import alternativa.engine3d.objects.MeshSetClone;
	/**
	 * Bounding volume hierachy ( in the form of hierachical bounding boxes) TODO:
	 *
	 * @author Glenn Ko
	 */
	public class BVHCuller implements IMeshSetCloneCuller
	{
		
		public function BVHCuller() 
		{
			
		}
		
		//public function addBoundingBoxWithClone(
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetCloneCuller */
		
		public function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>):int 
		{
			
		}
		
	}

}