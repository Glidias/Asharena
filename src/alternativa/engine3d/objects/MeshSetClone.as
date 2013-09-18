package alternativa.engine3d.objects 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	use namespace alternativa3d;
	/**
	 * Base class for MeshSetClonesContainer to hold dynamic reference to a cloned hierachy of meshes. 
	 * You can extend this class and assign it to a MeshSetClonesContainer to instantiate that instead.
	 * @author Glenn Ko
	 */
	public class MeshSetClone 
	{
		public var root:Object3D;
		public var surfaceMeshes:Vector.<Vector.<Mesh>>;
		alternativa3d var index:int;
	
		
		public function MeshSetClone() 
		{
			
		}
		
	}

}