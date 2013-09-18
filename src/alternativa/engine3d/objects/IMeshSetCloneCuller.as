package alternativa.engine3d.objects 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IMeshSetCloneCuller 
	{
		function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>, camera:Camera3D, object:Object3D):int;
	}
	
}