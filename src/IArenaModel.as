package  
{
	import ash.core.Entity;
	import ash.signals.Signal1;
	/**
	 * 
	 * @author Glenn Ko
	 */
	public interface IArenaModel 
	{
		
		function get playerEntityChanged():Signal1;
		function getPlayerEntity():Entity;
		
		
	}

}