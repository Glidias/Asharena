package arena.systems.islands.jobs;
import hashds.ds.IDLMixNode;

/**
 * ...
 * @author Glenn Ko
 */
class IsleJob implements IDLMixNode<IsleJob>
{
	public var next:IsleJob;
	public var prev:IsleJob;

	public function new() 
	{
		
	}
	
}