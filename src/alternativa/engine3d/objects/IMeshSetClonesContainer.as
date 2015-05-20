package alternativa.engine3d.objects 
{
	
	/**
	 * ...
	 * @author Glidias
	 */
	public interface IMeshSetClonesContainer 
	{
		
		function addClone(cloneItem:MeshSetClone):MeshSetClone;
		
		function removeClone(cloneItem:MeshSetClone):void;
	}
	
}