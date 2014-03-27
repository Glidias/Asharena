package arena.systems.enemy;
import arena.components.char.AggroMem;
import ash.core.Node.Node;
import components.Ellipsoid;
import components.Pos;
import components.Rot;

/**
 * ...
 * @author Glenn Ko
 */
class AggroMemNode extends Node<AggroMemNode>
{
	public var mem:AggroMem;
	public var pos:Pos;
	public var rot:Rot;
	public var size:Ellipsoid;
	
	
	public function new() 
	{
		
	}
	
}