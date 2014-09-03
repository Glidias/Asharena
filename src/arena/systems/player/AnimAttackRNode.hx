package arena.systems.player;
import arena.components.weapon.AnimAttackRanged;
import arena.components.weapon.Weapon;
import ash.core.Node;
import components.ActionIntSignal;
import components.Ellipsoid;
import components.Pos;

/**
 * ...
 * @author Glidias
 */
class AnimAttackRNode extends Node<AnimAttackRNode>
{
	public var animRanged:AnimAttackRanged;
	public var signal:ActionIntSignal;
	public var weapon:Weapon;
	public var pos:Pos;

	
	public function new() 
	{
		
	}
	
}