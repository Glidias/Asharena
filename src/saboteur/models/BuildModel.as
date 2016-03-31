package saboteur.models 
{
	/**
	 * Plain implementation of BuildModel with dispatching changes
	 * @author Glenn o
	 */
	public class BuildModel implements IBuildModel 
	{
		private var curBuildId:int = -1; // -1;  // 63
		
		
		
		public function BuildModel() 
		{
			
		}
		
		/* INTERFACE saboteur.models.IBuildModel */
		public function setBuildId(val:int):void  {
			curBuildId = val;
			validateVis();
		}
		public function getCurBuildID():int {
			return curBuildId;
		}
		public function attemptBuild():Boolean 
		{
			
		}
		
		
		
	}

}