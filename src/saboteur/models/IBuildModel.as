package saboteur.models 
{
	
	/**
	 * Selection state of build
	 * @author Glenn Ko
	 */
	public interface IBuildModel 
	{
		// negative buildIds refer to null build id selections
		function setBuildId(val:int):void;
		
		function getCurBuildID():int;
		
		
		
	}
	
}