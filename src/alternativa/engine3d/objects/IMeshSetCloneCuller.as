package alternativa.engine3d.objects 
{
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IMeshSetCloneCuller 
	{
		function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>):int;
	}
	
}