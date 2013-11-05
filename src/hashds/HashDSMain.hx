package hashds;
import arena.systems.islands.jobs.IsleJob;
import hashds.ds.DLMixList;
import hashds.ds.DMixPriorityList;
import hashds.ds.VectorIndex;

/**
 * ...
 * @author Glenn Ko
 */
class HashDSMain
{

	public function new() 
	{
	
		new DLMixList<IsleJob>();
		new DMixPriorityList<IsleJob>();
		new VectorIndex<IsleJob>();
	}
	
	public static function main():Void {
		
		
	}
	
}