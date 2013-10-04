package saboteur.models 
{
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IBuildModel 
	{
		
		function setBuildId(val:int):void;
		
		function getCurBuildID():int;
		
		function attemptBuild():Boolean;
		
	}
	
}