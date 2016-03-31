package saboteur.systems 
{
	
	/**
	 * Marker interface for any self-contained class instance that can remotely execute build/del path card attempts without specifying grid positions explicitly
	 * @author 
	 */
	public interface IBuildAttempter 
	{
		
		// return values determine if attempt is successful
		function attemptBuild():Boolean;
		function attemptDel():Boolean;
	}
	
}