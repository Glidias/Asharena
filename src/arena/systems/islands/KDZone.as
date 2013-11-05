package arena.systems.islands 
{
	import arena.systems.islands.jobs.IsleJob;
	import hashds.ds.VectorIndex_arena_systems_islands_jobs_IsleJob;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class KDZone 
	{
		public var root:KDNode;
		public var x:int;
		public var y:int;
		public var createIslandJobs:VectorIndex_arena_systems_islands_jobs_IsleJob;

		
		public function KDZone() 
		{
			createIslandJobs = new VectorIndex_arena_systems_islands_jobs_IsleJob();
		}
		
		public function toString():String {
			return "[KDZone "+x+", "+y+" ]"
		}
		
	}

}