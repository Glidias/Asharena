package saboteur.systems 
{
	
	/**
	 * Marker interface for any self-contained class instance that can remotely execute build path card attempts without specifying grid positions explicitly
	 * @author 
	 */
	public interface IBuildAttempter 
	{
		
		// return values determine if attempt is successful
		function attemptBuild():Boolean;
	//	function attemptDel(east:int, south:int):Boolean;  // seperation of concern.
	}
	
}