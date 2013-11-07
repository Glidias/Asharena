package hashds;
import arena.systems.islands.jobs.IsleJob;
import hashds.ds.alchemy.AlchemyUtil;
import hashds.ds.DLMixList;
import hashds.ds.DMixPriorityList;
import hashds.ds.VectorIndex;

/**
 * Compiles with Haxe v2.10
 * @author Glenn Ko
 */
class HashDSMain
{

	public function new() 
	{
	
		new DLMixList<IsleJob>();
		new DMixPriorityList<IsleJob>();
		new VectorIndex<IsleJob>();
		AlchemyUtil;
	}
	
	public static function main():Void {
		
		
	}
	
	
	
}