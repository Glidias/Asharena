package arena.systems.islands.jobs;
import hashds.ds.IDLMixNode;
import hashds.ds.Indexable;
import hashds.ds.IPrioritizable;


/**
 * ...
 * @author Glenn Ko
 */
class IsleJob implements IDLMixNode<IsleJob>, implements IPrioritizable, implements Indexable
{
	public var next:IsleJob;
	public var prev:IsleJob;
	
	public var priority:Float;
	public var index:Int;

	public function new() 
	{
		
	}
	
}